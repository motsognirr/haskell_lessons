# Lesson 09 -- Libraries: Aeson + Optparse-Applicative

In this lesson we leave the standard library behind and start using
real-world Haskell packages. We will add two widely-used libraries to our
`hask` note-taking app:

* **aeson** -- fast, reliable JSON encoding and decoding
* **optparse-applicative** -- declarative command-line option parsing

Along the way you will pick up just enough knowledge about the
`Applicative` typeclass to use optparse-applicative comfortably.

---

## 1  Finding Packages on Hackage

Hackage (<https://hackage.haskell.org>) is the central package repository
for Haskell. Every library you install with `cabal` comes from here.

Useful tips:

* Search by name or keyword on the Hackage front page.
* Each package page shows the API docs (Haddock), a description,
  dependencies, and download statistics.
* Stackage (<https://www.stackage.org>) curates *snapshots* of packages
  that are tested to work together -- handy when you want stability.
* To add a package to your project, put its name in the `build-depends`
  field of your `.cabal` file, then run `cabal build`.

---

## 2  Aeson -- JSON for Haskell

### 2.1  Why JSON?

In previous lessons we stored notes with `show` and read them back with
`read`. That works but is fragile: the format is Haskell-specific, and a
single unexpected character can cause a crash. JSON is a universal,
human-readable format supported by every language and tool.

### 2.2  The Core Typeclasses

Aeson revolves around two typeclasses:

```haskell
class ToJSON a where
  toJSON :: a -> Value          -- convert a value to JSON

class FromJSON a where
  parseJSON :: Value -> Parser a  -- parse JSON into a value
```

If your type has both instances you can round-trip it through JSON.

### 2.3  The Easy Way: DeriveGeneric

Writing `ToJSON` / `FromJSON` instances by hand is possible but tedious.
The easiest approach is to let GHC derive them via `Generic`:

```haskell
{-# LANGUAGE DeriveGeneric #-}

module Hask.Types where

import GHC.Generics (Generic)
import Data.Aeson   (ToJSON, FromJSON)

data Priority = Low | Medium | High
  deriving (Show, Read, Eq, Generic)

instance ToJSON   Priority
instance FromJSON Priority

data Note = Note
  { noteId    :: Int
  , title     :: String
  , body      :: String
  , tags      :: [String]
  , priority  :: Priority
  } deriving (Show, Read, Eq, Generic)

instance ToJSON   Note
instance FromJSON Note
```

What is happening here:

1. The `DeriveGeneric` language extension lets you add `Generic` to any
   `deriving` clause.
2. `Generic` gives GHC a structural representation of your type.
3. Aeson provides *default* `ToJSON` / `FromJSON` implementations that
   work for any `Generic` type. You just declare the empty instances.

### 2.4  Encoding and Decoding

```haskell
import Data.Aeson (encode, decode, eitherDecode)

-- Encoding (to JSON)
encode :: ToJSON a => a -> Data.ByteString.Lazy.ByteString

-- Decoding (from JSON)
decode       :: FromJSON a => ByteString -> Maybe a
eitherDecode :: FromJSON a => ByteString -> Either String a
```

`encode` produces a lazy `ByteString` containing the JSON text.
`decode` returns `Nothing` on failure; `eitherDecode` returns
`Left errorMsg` instead, which is much more useful for debugging.

For file I/O aeson provides convenience functions:

```haskell
import Data.Aeson (encodeFile, decodeFileStrict)

encodeFile     :: ToJSON a   => FilePath -> a -> IO ()
decodeFileStrict :: FromJSON a => FilePath -> IO (Maybe a)
```

These handle opening, reading, and closing the file for you.

### 2.5  ByteString vs String -- Brief Note

Haskell's `String` is a linked list of characters -- simple but slow for
large data. `ByteString` is a packed array of bytes, much faster for I/O.
Aeson uses `ByteString` internally, but the convenience file functions
(`encodeFile`, `decodeFileStrict`) let you avoid dealing with
`ByteString` directly in many cases.

When you do need to convert:

```haskell
import qualified Data.ByteString.Lazy as BL

-- Write JSON to a file manually
BL.writeFile "notes.json" (encode notes)

-- Read JSON from a file manually
bytes <- BL.readFile "notes.json"
let result = eitherDecode bytes :: Either String [Note]
```

---

## 3  Optparse-Applicative -- CLI Parsing

### 3.1  Why a Library?

Hand-rolling argument parsing with pattern matching on `getArgs` gets
painful fast. `optparse-applicative` gives you:

* Automatic `--help` generation
* Type-safe parsing
* Subcommands (like `git commit`, `git push`)
* Composable building blocks

### 3.2  The Parser Type

The central type is `Parser a` -- a description of how to parse command
line arguments into a value of type `a`.

You build small parsers and combine them using the `Applicative` pattern
(more on that in section 4).

### 3.3  Primitive Parsers

```haskell
import Options.Applicative

-- A required option:  --name "value"
strOption  :: Mod OptionFields String -> Parser String

-- A required option parsed via Read:  --count 42
option auto :: Read a => Mod OptionFields a -> Parser a

-- A boolean flag, default False:  --verbose
switch :: Mod FlagFields Bool -> Parser Bool

-- A positional argument:  <filename>
argument str  :: Mod ArgumentFields String -> Parser String
argument auto :: Read a => Mod ArgumentFields a -> Parser a
```

### 3.4  Modifiers

Modifiers configure how an option looks in help text and how it is
parsed:

```haskell
long    :: String -> Mod f a   -- --name
short   :: Char   -> Mod f a   -- -n
metavar :: String -> Mod f a   -- <NAME> in help
help    :: String -> Mod f a   -- description text
value   :: a      -> Mod f a   -- default value
```

Example:

```haskell
strOption
  (  long "output"
  <> short 'o'
  <> metavar "FILE"
  <> help "Write output to FILE"
  )
```

### 3.5  Subcommands

Many CLI tools use subcommands: `hask add`, `hask list`, `hask search`.
Optparse-applicative supports this with `subparser` and `command`:

```haskell
data Command
  = Add String
  | List
  | Search String

commandParser :: Parser Command
commandParser = subparser
  (  command "add"    (info addParser    (progDesc "Add a new note"))
  <> command "list"   (info listParser   (progDesc "List all notes"))
  <> command "search" (info searchParser (progDesc "Search notes"))
  )

addParser :: Parser Command
addParser = Add <$> argument str (metavar "TITLE")

listParser :: Parser Command
listParser = pure List

searchParser :: Parser Command
searchParser = Search <$> argument str (metavar "QUERY")
```

### 3.6  Running the Parser

```haskell
main :: IO ()
main = do
  cmd <- execParser opts
  case cmd of
    Add t    -> putStrLn ("Adding: " ++ t)
    List     -> putStrLn "Listing..."
    Search q -> putStrLn ("Searching: " ++ q)
  where
    opts = info (commandParser <**> helper)
      (  fullDesc
      <> progDesc "A note-taking app"
      <> header "hask - notes from the command line"
      )
```

`execParser` reads the actual command line arguments, runs the parser,
and either returns the parsed value or prints help/error and exits.

The `<**> helper` bit adds the automatic `--help` flag.

---

## 4  A Brief Applicative Explanation

You have already used `Functor` (`fmap` / `<$>`). `Applicative` adds one
more capability: applying a function that is *inside* a context to a
value that is also inside a context.

```haskell
class Functor f => Applicative f where
  pure  :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b
```

The pattern you will see constantly with optparse-applicative:

```haskell
data Config = Config String Int Bool

configParser :: Parser Config
configParser = Config
  <$> strOption (long "name"  <> help "Your name")
  <*> option auto (long "age" <> help "Your age")
  <*> switch (long "verbose"  <> help "Verbose output")
```

Read this as:

1. `Config` is a function `String -> Int -> Bool -> Config`.
2. `<$>` lifts it into the `Parser` world (like `fmap`).
3. Each `<*>` feeds in the next parsed argument.

The result is a `Parser Config` that knows how to parse all three
arguments and assemble them into a `Config`.

You do not need to understand applicative laws or deep theory to use this
pattern. Just remember:

```
MyType <$> parser1 <*> parser2 <*> parser3
```

---

## 5  Putting It All Together

After this lesson your `hask` app will:

1. Store notes as JSON in `notes.json` (human-readable, portable).
2. Parse commands like:
   - `hask add "My Note" --tags "haskell,fp" --priority high`
   - `hask list --tag haskell`
   - `hask search "some query"`
   - `hask delete 3`
3. Show proper `--help` output automatically.

The combination of aeson and optparse-applicative is so common in
Haskell CLI tools that you will see it in almost every real-world
project.

---

## Summary

| Concept                | Key Takeaway                                    |
|------------------------|-------------------------------------------------|
| Hackage                | Central package repository for Haskell          |
| aeson `ToJSON`         | Convert Haskell values to JSON                  |
| aeson `FromJSON`       | Parse JSON into Haskell values                  |
| `DeriveGeneric`        | Auto-derive JSON instances with minimal code    |
| `encode` / `decode`    | Core serialization functions                    |
| `eitherDecode`         | Like `decode` but with error messages           |
| optparse `Parser`      | Declarative CLI argument parser                 |
| `subparser` / `command`| Build subcommand-style CLIs                     |
| `execParser`           | Run the parser against real arguments           |
| Applicative pattern    | `MyType <$> p1 <*> p2 <*> p3`                  |

---

Next lesson: Testing with HSpec and QuickCheck.
