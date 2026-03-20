# Exercise 12 -- Polish & Ship

In this final exercise you will give the `hask` app a professional
finish: migrating to `Data.Text`, adding colored terminal output, and
implementing export commands.

---

## Part 1: Migrate to Data.Text

### 1.1  Update `hask.cabal`

Add `text` to your `build-depends`:

```cabal
  , text >= 1.2
```

### 1.2  Update `src/Hask/Types.hs`

1. Add the `OverloadedStrings` pragma at the top:

   ```haskell
   {-# LANGUAGE OverloadedStrings #-}
   ```

2. Import `Data.Text`:

   ```haskell
   import Data.Text (Text)
   ```

3. Change the `Note` type to use `Text` for string fields:

   ```haskell
   data Note = Note
     { noteId   :: Int
     , title    :: Text
     , body     :: Text
     , tags     :: [Text]
     , priority :: Priority
     } deriving (Show, Read, Eq, Generic)
   ```

4. The `ToJSON` / `FromJSON` instances need no changes -- aeson works
   natively with `Text`.

### 1.3  Update `src/Hask/Search.hs`

Switch from `Data.Char.toLower` and `Data.List.isInfixOf` to their
`Data.Text` equivalents:

```haskell
{-# LANGUAGE OverloadedStrings #-}

import Data.Text (Text)
import qualified Data.Text as T

searchNotes :: Text -> [Note] -> [Note]
searchNotes query = filter (matchesQuery (T.toLower query))

matchesQuery :: Text -> Note -> Bool
matchesQuery q note =
     q `T.isInfixOf` T.toLower (title note)
  || q `T.isInfixOf` T.toLower (body note)
  || any (\t -> q `T.isInfixOf` T.toLower t) (tags note)
```

### 1.4  Update Other Modules

Anywhere you work with `title`, `body`, or `tags`, you may need:

- `import Data.Text (Text, pack, unpack)` for conversions
- `import qualified Data.Text as T` for Text functions
- `import qualified Data.Text.IO as TIO` for Text I/O
- The `OverloadedStrings` pragma for string literals

Command-line arguments arrive as `String`, so use `pack` to convert
them to `Text` when creating notes.

---

## Part 2: Colored Output with ansi-terminal

### 2.1  Add the Dependency

Add to `build-depends`:

```cabal
  , ansi-terminal >= 0.11
```

### 2.2  Create `src/Hask/Display.hs`

Create a new module with colored printing helpers:

```haskell
module Hask.Display
  ( colorPutStrLn
  , successMsg
  , errorMsg
  , priorityColor
  , displayNote
  ) where
```

Implement these using `System.Console.ANSI`:

- `priorityColor :: Priority -> Color` -- High=Red, Medium=Yellow,
  Low=Green
- `colorPutStrLn :: Color -> String -> IO ()` -- print a line in the
  given color, then reset
- `successMsg :: String -> IO ()` -- print in green
- `errorMsg :: String -> IO ()` -- print in red
- `displayNote :: Note -> IO ()` -- pretty-print a single note with
  the priority shown in its color

### 2.3  Use Colors in the App

Update `src/Hask/App.hs` (or wherever your command handlers live) to
use the new display functions:

- After successfully adding a note: `successMsg "Added: ..."`
- After deleting a note: `successMsg "Deleted note ..."`
- On errors: `errorMsg "Error: ..."`
- When listing notes: use `displayNote` for each note

---

## Part 3: Export Command

### 3.1  Create `src/Hask/Export.hs`

Create a new module that can render `[Note]` in three formats:

```haskell
module Hask.Export
  ( ExportFormat(..)
  , exportNotes
  ) where
```

#### Markdown Format

Each note as a Markdown section:

```markdown
## My Note Title

Body text here.

**Priority:** High
**Tags:** haskell, fp

---
```

#### CSV Format

A header row followed by one row per note:

```
id,title,body,tags,priority
1,"My Note Title","Body text","haskell,fp","High"
```

Quote fields that might contain commas. Tags should be joined with
commas inside the quotes.

#### JSON Format

Pretty-printed JSON. You can use `Data.Aeson.encode` (or
`encodePretty` from `aeson-pretty` if you added that dependency)
and convert the `ByteString` to a `String`.

The `exportNotes` function should take the format and list of notes and
return a `String`:

```haskell
exportNotes :: ExportFormat -> [Note] -> String
```

### 3.2  Update `src/Hask/CLI.hs`

Add an `Export` constructor to your `Command` type:

```haskell
data Command
  = Add AddOpts
  | List ListOpts
  | Search String
  | Delete Int
  | Export ExportFormat    -- NEW
```

Add a parser for the export subcommand:

```
hask export --format md
hask export --format csv
hask export --format json
```

Use `strOption (long "format" <> ...)` and parse the string into an
`ExportFormat`.

### 3.3  Handle the Export Command

In your command handler, load the notes and print the exported text:

```haskell
handleExport :: ExportFormat -> IO ()
handleExport fmt = do
    result <- loadNotes notesFile
    case result of
      Left err    -> errorMsg ("Error: " ++ err)
      Right notes -> putStrLn (exportNotes fmt notes)
```

---

## Part 4: Update the Cabal File

Make sure `hask.cabal` lists all new modules and dependencies:

```cabal
build-depends:
    base >= 4.14 && < 5
  , aeson
  , bytestring
  , directory
  , optparse-applicative
  , text
  , ansi-terminal

other-modules:
    Hask.Types
    Hask.Search
    Hask.Storage
    Hask.Error
    Hask.CLI
    Hask.App
    Hask.Export
    Hask.Display
```

---

## Part 5: Verify

1. **Build**: `cabal build` should succeed with no errors.
2. **Test**: `cabal test` -- all existing tests should still pass.
3. **Manual check**: try these commands:

   ```bash
   hask add "Final Note" --tags "polish,done" --priority high
   hask list
   hask export --format md
   hask export --format csv
   hask export --format json
   ```

---

## Checklist

- [ ] `hask.cabal` includes `text` and `ansi-terminal` in build-depends
- [ ] `Hask.Types` uses `Text` for `title`, `body`, and `tags`
- [ ] `OverloadedStrings` pragma is present where needed
- [ ] Search module uses `Data.Text` functions
- [ ] `Hask.Display` module exists with colored output helpers
- [ ] Priority colors: High=Red, Medium=Yellow, Low=Green
- [ ] Success messages print in green, errors in red
- [ ] `hask export --format md` outputs Markdown
- [ ] `hask export --format csv` outputs CSV
- [ ] `hask export --format json` outputs JSON
- [ ] `Hask.Export` is listed in other-modules in the cabal file
- [ ] `Hask.Display` is listed in other-modules in the cabal file
- [ ] `cabal build` compiles cleanly
- [ ] `cabal test` passes

---

## Bonus Challenges

1. **Install globally**: run `cabal install` and verify `hask` works
   from any directory.
2. **Export to file**: add an optional `--output <file>` flag to the
   export command that writes to a file instead of stdout.
3. **Colorized Markdown**: when exporting to stdout (not a file), add
   ANSI colors to the Markdown output for terminal viewing.
4. **Shell completions**: use optparse-applicative's bash/zsh completion
   support to generate shell completions for `hask`.
