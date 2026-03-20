# Exercise 08: Error Handling in hask

Add proper error handling to the `hask` app so that it never crashes on bad
input, missing notes, or storage problems. Instead it should display friendly
error messages.

## What to Build

### 1. `app/src/Hask/Error.hs` -- Error type module

Create a new module `Hask.Error` that defines:

```haskell
data HaskError
  = NoteNotFound Int
  | InvalidCommand String
  | StorageError String
  | ParseError String
  deriving (Show, Eq)
```

And a function to format errors for the user:

```haskell
formatError :: HaskError -> String
```

- `NoteNotFound 42`       -> `"Error: note 42 not found."`
- `InvalidCommand "foo"`  -> `"Error: unknown command 'foo'. Run hask with no arguments for usage."`
- `StorageError msg`      -> `"Error: could not access storage -- " ++ msg`
- `ParseError msg`        -> `"Error: " ++ msg`

### 2. Refactor `app/src/Hask/Storage.hs` -- Safe storage operations

Update `loadNotes` so it returns `IO (Either HaskError [Note])` instead of
`IO [Note]`. If the file does not exist, return `Right []` (not an error).
If the file exists but cannot be parsed, return `Left (ParseError ...)`.

Add a `deleteNote` function:

```haskell
deleteNote :: Int -> IO (Either HaskError ())
```

It should load notes, find the note with the given ID, remove it, and save
the updated list. If no note with that ID exists, return
`Left (NoteNotFound id)`.

### 3. Update `app/src/Main.hs` -- Graceful command handling

Refactor `main` so that:

- **`hask add <text>`** -- adds a note (existing behaviour, but handle storage errors)
- **`hask list`** -- lists all notes (handle storage errors)
- **`hask search <query>`** -- searches notes (handle storage errors)
- **`hask delete <id>`** -- deletes a note by ID; shows error if not found
- **No arguments** -- prints usage information
- **Unknown command** -- prints a friendly error using `formatError (InvalidCommand cmd)`
  and then prints usage. The output must include the word "Usage".

All commands that can fail should display the user-friendly error message
from `formatError` rather than crashing.

### 4. Update `app/hask.cabal`

Add `Hask.Error` to the `other-modules` list.

## Requirements

- The project must compile: `cd app && cabal build`
- `hask delete 999` must output text containing "not found" (case-insensitive check)
- `hask add "Delete Me"` followed by `hask delete 1` should succeed, and
  `hask list` afterwards should show no notes (or not show the deleted note)
- `hask badcommand` must output text containing "Usage" -- it should not crash
- `HaskError` type must have all four constructors

## Hints

- Use `System.Directory (doesFileExist)` to check for the file before reading
- `reads :: String -> [(a, String)]` is a safe alternative to `read` --
  it returns an empty list if parsing fails instead of crashing
- For `deleteNote`, load notes, filter out the matching ID, check whether the
  length actually changed (to detect "not found"), then save
- When deleting, you should clean up the `notes.dat` file first with
  `rm -f notes.dat` in your testing so IDs start fresh
- In Main.hs, a helper like `handleResult :: Either HaskError () -> IO ()`
  can reduce repetition
- Remember to import `Hask.Error` in both Main.hs and Storage.hs
