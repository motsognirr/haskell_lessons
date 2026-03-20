# Exercise 07: Adding Persistence to hask

## Goal

Add file-based persistence to the `hask` note manager so that notes survive
between runs. You will create a new `Hask.Storage` module and update `Main.hs`
to support `add`, `list`, and `search` commands.

---

## Step 1: Update Types for Serialization

Open `app/src/Hask/Types.hs` and add `Read` to the `deriving` clauses of both
`Priority` and `Note`:

```haskell
data Priority = Low | Medium | High
  deriving (Show, Read, Eq, Ord)

data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Read, Eq)
```

This lets us use `show` and `read` to serialize notes to a file.

---

## Step 2: Create `Hask.Storage`

Create the file `app/src/Hask/Storage.hs` with the following exports:

```haskell
module Hask.Storage
  ( saveNotes
  , loadNotes
  , getNextId
  ) where
```

You will need to import:
- `Hask.Types` (for `Note` and its fields)
- `System.Directory` (for `doesFileExist`)

### Functions to implement

**`saveNotes :: FilePath -> [Note] -> IO ()`**

Write the list of notes to the given file path using `show`:

```haskell
saveNotes path notes = writeFile path (show notes)
```

**`loadNotes :: FilePath -> IO [Note]`**

Read notes from a file. If the file does not exist, return an empty list:

1. Check if the file exists with `doesFileExist`
2. If it exists, read the file and use `read` to parse the contents
3. If it does not exist, return `[]`

**`getNextId :: [Note] -> Int`**

Compute the next available ID:
- If the list is empty, return `1`
- Otherwise, find the maximum `noteId` and add 1

Hint: `maximum (map noteId notes) + 1`

---

## Step 3: Update `hask.cabal`

Open `app/hask.cabal` and make two changes:

1. Add `Hask.Storage` to `other-modules`:

```
  other-modules:
    Hask.Types
    Hask.Search
    Hask.Storage
```

2. Add `directory` to `build-depends`:

```
  build-depends:
    base >= 4.14 && < 5
    , directory
```

---

## Step 4: Update `Main.hs`

Replace the sample notes and update `main` to use persistence.

Notes are stored in `notes.dat` (in the current directory).

### Commands to support

**`hask add <title>`** -- Add a new note:
1. Load existing notes from `notes.dat`
2. Compute the next ID with `getNextId`
3. Create a new `Note` with the given title, empty body `""`, no tags `[]`,
   and priority `Medium`
4. Save the updated list (existing notes ++ [new note])
5. Print a confirmation, e.g., `"Added: <title>"`

**`hask list`** -- List all notes:
1. Load notes from `notes.dat`
2. If empty, print `"No notes yet."`
3. Otherwise, print each note's title (one per line)

**`hask search <query>`** -- Search notes:
1. Load notes from `notes.dat`
2. Use `searchNotes` from `Hask.Search`
3. If no results, print `"No notes found."`
4. Otherwise, print matching note titles

### Example main structure

```haskell
module Main where

import System.Environment (getArgs)
import Hask.Types
import Hask.Search
import Hask.Storage

notesFile :: FilePath
notesFile = "notes.dat"

main :: IO ()
main = do
    args <- getArgs
    case args of
      ("add":titleStr:_) -> do
          -- load, compute next id, create note, save, confirm
      ["list"] -> do
          -- load and display
      ("search":query:_) -> do
          -- load, search, display
      _ -> putStrLn "Usage: hask <add|list|search> [args]"
```

---

## Testing Your Solution

Build and test from the `app/` directory:

```bash
cd app
cabal build

# Clean start
rm -f notes.dat

# Add some notes
cabal run hask -- add "Learn Haskell"
cabal run hask -- add "Buy groceries"
cabal run hask -- add "Haskell project"

# List all notes
cabal run hask -- list

# Search
cabal run hask -- search "haskell"
```

You should see:
- `list` shows all three titles
- `search "haskell"` shows "Learn Haskell" and "Haskell project"
- Quitting and re-running `list` still shows the notes (persistence!)

---

## Checklist

- [ ] `Hask.Types` has `Read` in its `deriving` clauses
- [ ] `app/src/Hask/Storage.hs` exists with `saveNotes`, `loadNotes`, `getNextId`
- [ ] `app/hask.cabal` includes `Hask.Storage` and `directory` dependency
- [ ] `app/src/Main.hs` handles `add`, `list`, and `search` commands
- [ ] `cabal build` succeeds
- [ ] Notes persist between runs
