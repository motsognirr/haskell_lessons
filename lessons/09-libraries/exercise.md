# Exercise 09 -- Libraries: Aeson + Optparse-Applicative

In this exercise you will upgrade the `hask` note-taking app to use
**JSON storage** (via aeson) and **proper CLI parsing** (via
optparse-applicative).

---

## Part 1: JSON Storage with Aeson

### 1.1  Update `hask.cabal`

Add these to your `build-depends`:

```
    aeson              >= 2.0,
    bytestring         >= 0.10,
    optparse-applicative >= 0.16
```

### 1.2  Update `src/Hask/Types.hs`

1. Add the `DeriveGeneric` language pragma at the top of the file:

   ```haskell
   {-# LANGUAGE DeriveGeneric #-}
   ```

2. Import `GHC.Generics` and `Data.Aeson`:

   ```haskell
   import GHC.Generics (Generic)
   import Data.Aeson   (ToJSON, FromJSON)
   ```

3. Add `Generic` to the `deriving` clause of every data type
   (`Priority`, `Note`, and any others).

4. Add empty `ToJSON` and `FromJSON` instances for each type:

   ```haskell
   instance ToJSON   Priority
   instance FromJSON Priority

   instance ToJSON   Note
   instance FromJSON Note
   ```

### 1.3  Update `src/Hask/Storage.hs`

Switch from `show`/`read` to JSON:

1. Change the storage file from `notes.dat` to `notes.json`.

2. For **saving**, use `Data.Aeson.encodeFile`:

   ```haskell
   import Data.Aeson (encodeFile)

   saveNotes :: FilePath -> [Note] -> IO ()
   saveNotes path notes = encodeFile path notes
   ```

   Alternatively, use `encode` from `Data.Aeson` together with
   `Data.ByteString.Lazy.writeFile`.

3. For **loading**, use `Data.Aeson.decodeFileStrict` (or read the file
   as a lazy `ByteString` and use `eitherDecode`):

   ```haskell
   import Data.Aeson (eitherDecode)
   import qualified Data.ByteString.Lazy as BL

   loadNotes :: FilePath -> IO (Either String [Note])
   loadNotes path = do
     exists <- doesFileExist path
     if not exists
       then return (Right [])
       else do
         bytes <- BL.readFile path
         return (eitherDecode bytes)
   ```

---

## Part 2: CLI Parsing with Optparse-Applicative

### 2.1  Define a Command type

Create a `src/Hask/CLI.hs` module (or put this in `Types.hs`):

```haskell
data Command
  = Add    AddOpts
  | List   ListOpts
  | Search String
  | Delete Int

data AddOpts = AddOpts
  { addTitle    :: String
  , addTags     :: String      -- comma-separated, e.g. "haskell,fp"
  , addPriority :: Priority
  }

data ListOpts = ListOpts
  { listTag :: Maybe String    -- optional --tag filter
  }
```

### 2.2  Build the parsers

Use optparse-applicative to build a parser for each command:

```
hask add <title> [--tags "a,b"] [--priority low|medium|high]
hask list [--tag <tag>]
hask search <query>
hask delete <id>
```

Hints:

* Use `argument str (metavar "TITLE")` for positional arguments.
* Use `strOption (long "tags" <> value "" <> ...)` for optional string
  options with a default.
* Use `option auto (long "priority" <> value Medium <> ...)` for the
  priority (this works because `Priority` has a `Read` instance).
* Use `optional (strOption (long "tag" <> ...))` for `Maybe String`.
* Use `subparser` with `command` to combine them.

### 2.3  Wire it up in Main.hs

Replace the old `getArgs` / pattern-match logic with:

```haskell
import Options.Applicative

main :: IO ()
main = do
  cmd <- execParser opts
  case cmd of
    Add addOpts   -> handleAdd addOpts
    List listOpts -> handleList listOpts
    Search query  -> handleSearch query
    Delete noteId -> handleDelete noteId
  where
    opts = info (commandParser <**> helper)
      (  fullDesc
      <> progDesc "A note-taking CLI app"
      <> header "hask - notes from the command line"
      )
```

---

## Part 3: Tag Parsing

Tags come in as a comma-separated string like `"haskell,fp,types"`.
Write a small helper to split them:

```haskell
splitTags :: String -> [String]
splitTags "" = []
splitTags s  = case break (== ',') s of
  (tag, "")       -> [tag]
  (tag, _ : rest) -> tag : splitTags rest
```

Use this when creating a `Note` from `AddOpts`.

---

## Part 4: List Filtering

When the user passes `--tag haskell`, filter the note list to only show
notes that contain that tag:

```haskell
handleList :: ListOpts -> IO ()
handleList (ListOpts maybeTag) = do
  result <- loadNotes notesFile
  case result of
    Left err    -> putStrLn ("Error: " ++ err)
    Right notes ->
      let filtered = case maybeTag of
            Nothing  -> notes
            Just tag -> filter (elem tag . tags) notes
      in mapM_ printNote filtered
```

---

## Checklist

- [ ] `hask.cabal` includes `aeson`, `optparse-applicative`, `bytestring`
- [ ] Types have `DeriveGeneric` pragma and `Generic` deriving
- [ ] Types have `ToJSON` and `FromJSON` instances
- [ ] Storage uses JSON (`notes.json`)
- [ ] `hask add "My Note" --tags "a,b" --priority high` works
- [ ] `hask list` shows all notes
- [ ] `hask list --tag a` filters by tag
- [ ] `hask search "query"` searches notes
- [ ] `hask delete 1` removes a note
- [ ] `hask --help` and `hask add --help` show usage info

---

## Bonus Challenges

1. **Pretty printing**: Format the JSON output with `encodePretty` from
   the `aeson-pretty` package.
2. **Body input**: If no body is given on the command line, read it from
   stdin (multi-line, end with Ctrl-D).
3. **Sort options**: Add `--sort-by priority|title|id` to the `list`
   command.
