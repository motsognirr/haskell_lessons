# Lesson 12: Polish & Ship

This is the final lesson. We will take the `hask` CLI app and give it a
professional finish: migrating string fields to `Data.Text`, adding
colored terminal output, implementing export commands, and preparing the
binary for installation.

---

## 1  Data.Text vs String

### 1.1  Why String is Slow

Haskell's `String` type is defined as:

```haskell
type String = [Char]
```

That is a **linked list of characters**. Every character is a separate
heap object with a pointer to the next one. For a 1000-character string
you get 1000 cons cells, each containing a `Char` and a pointer. This
is catastrophically wasteful in both time and space:

- **Memory**: roughly 24 bytes per character on a 64-bit system (the
  `Char` itself + two pointers for the list spine).
- **Cache locality**: terrible. Each cons cell can be anywhere in
  memory, so the CPU cache cannot help you.
- **Concatenation**: O(n) because you must walk the entire first list.

For small strings in toy programs this is fine. For real applications
handling user input, file contents, or network data, it is not.

### 1.2  Text: Packed UTF-16

The `text` package provides `Data.Text`:

```haskell
-- Internally: a packed array of UTF-16 code units
-- (as of text-2.0, it uses UTF-8 internally, but the API is the same)
```

Benefits:

- **Compact**: characters are stored contiguously in an array.
- **Fast**: slicing, searching, and concatenation are dramatically
  faster than linked-list operations.
- **Correct**: full Unicode support out of the box.

### 1.3  The OverloadedStrings Extension

By default, a string literal `"hello"` has type `String`. With the
`OverloadedStrings` language extension, string literals become
polymorphic -- they can be `String`, `Text`, `ByteString`, or any type
with an `IsString` instance:

```haskell
{-# LANGUAGE OverloadedStrings #-}

import Data.Text (Text)

greeting :: Text
greeting = "hello"   -- no pack needed, the literal IS a Text value
```

Add this pragma to every module that uses `Text` literals.

### 1.4  Conversion Functions

When you need to interface between `String` and `Text`:

```haskell
import Data.Text (pack, unpack)

pack   :: String -> Text
unpack :: Text   -> String
```

Rule of thumb: **use `Text` everywhere internally** and only convert at
the boundaries (command-line arguments come in as `String`, some
libraries expect `String`).

### 1.5  Text Equivalents of Common Functions

Most `Prelude` string functions have `Text` counterparts:

| String / Prelude      | Data.Text equivalent |
|-----------------------|----------------------|
| `length`              | `T.length`           |
| `++`                  | `T.append` or `<>`   |
| `map`                 | `T.map`              |
| `words`               | `T.words`            |
| `unwords`             | `T.unwords`          |
| `toLower` (Data.Char) | `T.toLower`          |
| `isInfixOf`           | `T.isInfixOf`        |
| `splitOn`             | `T.splitOn`          |
| `intercalate`         | `T.intercalate`      |
| `putStrLn`            | `TIO.putStrLn`       |

---

## 2  The text Package and Imports

The conventional import style:

```haskell
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
```

- Import the `Text` type unqualified (you use it in type signatures
  constantly).
- Import functions qualified so they do not clash with `Prelude`
  (`T.length` vs `length`, `TIO.putStrLn` vs `putStrLn`).

### Updating the Cabal File

Add `text` to your `build-depends`:

```cabal
build-depends:
    base >= 4.14 && < 5
  , text >= 1.2
  , ...
```

The `text` package ships with GHC, so you do not need to download
anything -- but you do need to list it explicitly.

### Aeson and Text

Good news: `aeson` works **natively** with `Text`. In fact, JSON string
values are represented internally as `Text` in aeson. If your record
fields are `Text`, the auto-derived `ToJSON` / `FromJSON` instances work
with zero changes. This is one more reason to prefer `Text` over
`String`.

---

## 3  ANSI Terminal Colors with ansi-terminal

The `ansi-terminal` package lets you print colored text to the terminal.
It works on Linux, macOS, and Windows.

### 3.1  Installation

Add to `build-depends`:

```cabal
  , ansi-terminal >= 0.11
```

### 3.2  Core API

```haskell
import System.Console.ANSI

-- Set graphics rendition (color, bold, etc.)
setSGR :: [SGR] -> IO ()

-- Reset to default
setSGR [Reset]
```

`SGR` (Select Graphic Rendition) values control appearance:

```haskell
-- Set the foreground (text) color
SetColor Foreground Vivid Red
SetColor Foreground Dull  Blue

-- Set the background color
SetColor Background Vivid Yellow

-- Set bold
SetConsoleIntensity BoldIntensity
```

### 3.3  Available Colors

The `Color` type has eight constructors:

```
Black  Red  Green  Yellow  Blue  Magenta  Cyan  White
```

Each can be `Vivid` (bright) or `Dull` (dark), giving you 16 foreground
and 16 background colors.

### 3.4  Practical Pattern: Colored Printing Helper

A common pattern is a helper function:

```haskell
colorPutStrLn :: Color -> String -> IO ()
colorPutStrLn color msg = do
    setSGR [SetColor Foreground Vivid color]
    putStrLn msg
    setSGR [Reset]
```

**Always reset** after printing colored text. If you forget, all
subsequent terminal output will be in that color.

### 3.5  Applying Colors to hask

Practical uses in our app:

- **Priority display**: High = Red, Medium = Yellow, Low = Green
- **Success messages**: "Added note" in green
- **Error messages**: "Error: ..." in red
- **Tags**: in cyan for visual distinction

```haskell
priorityColor :: Priority -> Color
priorityColor High   = Red
priorityColor Medium = Yellow
priorityColor Low    = Green
```

---

## 4  Export Formats

A polished CLI app should let users get their data out. We will add
three export formats:

### 4.1  Markdown Export

Each note becomes a Markdown section:

```markdown
## My Note Title

Body text here.

**Priority:** High
**Tags:** haskell, fp
```

Implementation: walk the list of notes and concatenate formatted
strings.

### 4.2  CSV Export

Standard comma-separated values with a header row:

```
id,title,body,tags,priority
1,"My Note Title","Body text","haskell,fp","High"
```

Be careful to quote fields that might contain commas.

### 4.3  JSON Export

We already have JSON via aeson. For export, use `encodePretty` from the
`aeson-pretty` package (or just `encode` from `aeson` and convert to a
readable string):

```haskell
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy.Char8 as BLC

exportJson :: [Note] -> String
exportJson = BLC.unpack . encodePretty
```

Alternatively, you can use plain `encode` and skip the extra dependency.

---

## 5  Building and Installing

### 5.1  cabal install

Once your app is polished, you can install the binary so it is available
system-wide (or at least in your PATH):

```bash
cabal install
```

This compiles the project and copies the binary to `~/.cabal/bin/`.
Make sure `~/.cabal/bin` is on your `PATH`.

If you want to overwrite an existing installation:

```bash
cabal install --install-method=copy --overwrite-policy=always
```

### 5.2  Verifying

```bash
which hask         # should show ~/.cabal/bin/hask
hask --help        # should show the help text
hask list          # should work from any directory
```

---

## 6  Course Wrap-Up

Congratulations -- you have built a real Haskell application from
scratch. Along the way you have learned:

| Lesson | Topic                              |
|--------|------------------------------------|
| 00     | Setup and tooling                  |
| 01     | Types and functions                |
| 02     | Lists and pattern matching         |
| 03     | Recursion and higher-order functions|
| 04     | Algebraic data types               |
| 05     | Typeclasses                        |
| 06     | Modules and project structure      |
| 07     | IO and file handling               |
| 08     | Error handling (Maybe, Either)     |
| 09     | Libraries (aeson, optparse)        |
| 10     | Monads and transformers            |
| 11     | Testing (HSpec, QuickCheck)        |
| 12     | Polish and ship                    |

### Where to Go Next

1. **Haskell Programming from First Principles** (the "Haskell Book")
   by Christopher Allen and Julie Moronuki -- the most thorough
   beginner-to-intermediate resource.

2. **Real World Haskell** by Bryan O'Sullivan, Don Stewart, and John
   Goerzen -- freely available at <http://book.realworldhaskell.org/>.
   Slightly dated but excellent for practical patterns.

3. **Typeclassopedia** by Brent Yorgey -- a tour of the Haskell
   typeclass hierarchy (Functor, Applicative, Monad, Traversable,
   etc.). Available on the Haskell Wiki.

4. **Learn You a Haskell for Great Good** -- a lighthearted
   introduction, freely available at <http://learnyouahaskell.com/>.

5. **Haskell in Depth** by Vitaly Bragilevsky -- intermediate to
   advanced topics, great after you are comfortable with the basics.

### Ideas for Continuing the hask Project

- Add a `hask edit <id>` command to modify existing notes.
- Store notes in an SQLite database using the `sqlite-simple` package.
- Add a `hask serve` command that exposes a REST API (using `scotty`
  or `servant`).
- Package the project with Nix for reproducible builds.
- Publish it on Hackage.

### Final Thought

Haskell rewards persistence. The type system that feels strict at first
becomes your most powerful tool -- catching bugs at compile time that
would slip through in other languages. Keep building, keep reading type
errors carefully, and enjoy the journey.

---

## Summary

| Topic                | Key takeaway                                       |
|----------------------|----------------------------------------------------|
| `Data.Text`          | Packed UTF-16/8 array, fast and compact             |
| `String = [Char]`    | Linked list, slow, avoid in real apps               |
| `OverloadedStrings`  | Lets string literals be `Text` directly             |
| `pack` / `unpack`    | Convert between `String` and `Text`                 |
| `ansi-terminal`      | `setSGR` for colors, always `Reset` when done       |
| Markdown export      | Notes as headings with body, priority, tags         |
| CSV export           | Header row + quoted fields                          |
| `cabal install`      | Puts binary in `~/.cabal/bin`                       |
| Next steps           | Haskell Book, Real World Haskell, Typeclassopedia   |
