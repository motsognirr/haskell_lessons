# Exercise 10: Refactor hask to Use a Monad Stack

Refactor the `hask` application to use a proper monad transformer stack instead
of manually threading `IO (Either HaskError ...)` through every handler.

## Overview

You will:
1. Create a new `Hask.App` module defining the `App` monad
2. Refactor command handlers (in `Storage.hs`) to use the `App` monad
3. Update `Main.hs` to run handlers through `runApp`
4. Add a `--file` CLI option so users can specify a custom notes file path
5. Add `mtl` to `build-depends` in `hask.cabal`

---

## Step 1: Create `app/src/Hask/App.hs`

Create a new module `Hask.App` with the following definitions:

### AppConfig

```haskell
data AppConfig = AppConfig
  { notesFile :: FilePath
  , verbose   :: Bool
  }
```

This holds runtime configuration that any handler might need. `notesFile` is the
path to the JSON file, and `verbose` controls debug output.

### The App type

```haskell
type App a = ExceptT HaskError (ReaderT AppConfig IO) a
```

This is the monad stack: `ExceptT` for error handling, `ReaderT` for config,
`IO` at the base for side effects.

### runApp

```haskell
runApp :: AppConfig -> App a -> IO (Either HaskError a)
runApp config action = runReaderT (runExceptT action) config
```

Unwraps the monad stack: provide the config, run the action, get back
`IO (Either HaskError a)`.

### throwHaskError

```haskell
throwHaskError :: HaskError -> App a
throwHaskError = throwError
```

A convenience wrapper around `throwError` with the type pinned to `App`.

### Imports you will need

```haskell
import Control.Monad.Except  (ExceptT, runExceptT, throwError)
import Control.Monad.Reader  (ReaderT, runReaderT, asks)
import Control.Monad.IO.Class (liftIO)
import Hask.Error (HaskError(..))
```

---

## Step 2: Refactor `app/src/Hask/Storage.hs`

Change the handler functions to work in the `App` monad instead of returning
`IO (Either HaskError ...)`.

### Before (example)

```haskell
addNote :: String -> IO (Either HaskError ())
addNote title = do
    result <- loadNotesFromFile "notes.json"
    case result of
      Left err -> return (Left err)
      Right notes -> do
        let newId = if null notes then 1 else maximum (map noteId notes) + 1
            note  = Note newId title "" [] Medium
        saveResult <- saveNotesToFile "notes.json" (notes ++ [note])
        return saveResult
```

### After

```haskell
addNote :: String -> App ()
addNote title = do
    path  <- asks notesFile
    notes <- loadNotes path
    let newId = if null notes then 1 else maximum (map noteId notes) + 1
        note  = Note newId title "" [] Medium
    saveNotes path (notes ++ [note])
```

### Key changes

- **Return type**: `IO (Either HaskError ())` becomes `App ()`
- **File path**: Use `asks notesFile` instead of a hardcoded `"notes.json"`
- **Error handling**: Use `throwError` (or `throwHaskError`) instead of
  `return (Left err)`. Errors propagate automatically -- no manual `case`.
- **IO actions**: Wrap with `liftIO` (e.g., `liftIO $ putStrLn "..."`)
- **Loading/saving helpers**: Refactor `loadNotes` and `saveNotes` to work in
  `App` as well, using `liftIO` for the actual file operations and
  `throwError` for parse/IO errors.

### Functions to refactor

Refactor all command handlers:
- `addNote :: String -> App ()`
- `listNotes :: App ()` (print notes inside the App monad)
- `deleteNote :: Int -> App ()`
- `searchNotes :: String -> App ()` (if you have it as a handler)

And the storage helpers:
- `loadNotes :: FilePath -> App [Note]`
- `saveNotes :: FilePath -> [Note] -> App ()`

For `loadNotes`, catch IO exceptions and convert them to `HaskError`:

```haskell
loadNotes :: FilePath -> App [Note]
loadNotes path = do
    exists <- liftIO $ doesFileExist path
    if not exists
      then return []
      else do
        contents <- liftIO $ BS.readFile path
        case eitherDecode contents of
          Left msg  -> throwError (ParseError msg)
          Right notes -> return notes
```

---

## Step 3: Update `app/src/Hask/CLI.hs`

Add a `--file` option to the CLI parser so users can specify a custom notes file:

```haskell
data Options = Options
  { optCommand :: Command
  , optFile    :: FilePath    -- NEW: --file flag
  }
```

Add the parser for it:

```haskell
optionsParser :: Parser Options
optionsParser = Options
    <$> commandParser
    <*> strOption
          ( long "file"
         <> short 'f'
         <> metavar "FILE"
         <> value "notes.json"
         <> help "Path to the notes file"
          )
```

The default value `"notes.json"` means existing behavior is unchanged unless
the user explicitly passes `--file`.

---

## Step 4: Update `app/src/Main.hs`

Wire everything together:

1. Parse CLI options to get `Options`
2. Build an `AppConfig` from the options
3. Run the appropriate handler through `runApp`
4. Pattern match on the result to display errors

```haskell
main :: IO ()
main = do
    opts <- execParser optsInfo
    let config = AppConfig
          { notesFile = optFile opts
          , verbose   = False
          }
    result <- runApp config (dispatch (optCommand opts))
    case result of
      Left err -> putStrLn (formatError err)
      Right _  -> return ()
```

Where `dispatch` maps commands to handlers:

```haskell
dispatch :: Command -> App ()
dispatch (Add title)    = addNote title
dispatch List           = listNotes
dispatch (Delete nid)   = deleteNote nid
dispatch (Search query) = searchNotesCmd query
```

---

## Step 5: Update `app/hask.cabal`

Add `mtl` to the build-depends and `Hask.App` to other-modules:

```cabal
build-depends:
  base >= 4.14 && < 5,
  aeson,
  bytestring,
  optparse-applicative,
  directory,
  mtl
other-modules:
  Hask.Types
  Hask.Search
  Hask.Storage
  Hask.Error
  Hask.CLI
  Hask.App
```

---

## Requirements

- The project must compile with `cabal build`
- `cabal run hask -- add "Test Note"` must still work
- `cabal run hask -- list` must display saved notes
- `cabal run hask -- delete 999` must display a "not found" error message
- `cabal run hask -- --file custom.json add "Custom"` must save to `custom.json`
- No hardcoded file paths in handlers -- always use `asks notesFile`

## Hints

- Import `Control.Monad.Except` for `ExceptT`, `throwError`, `runExceptT`
- Import `Control.Monad.Reader` for `ReaderT`, `asks`, `runReaderT`
- Import `Control.Monad.IO.Class` for `liftIO`
- All these come from the `mtl` package
- The order of the stack matters: `ExceptT` on the outside, `ReaderT` in the
  middle, `IO` at the base
- `runApp config action = runReaderT (runExceptT action) config`
- Start by creating `App.hs`, then refactor one handler at a time
- Test after each handler to make sure things still work
