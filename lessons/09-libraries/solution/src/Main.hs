module Main (main) where

import Options.Applicative (execParser)

import Hask.CLI
import Hask.Types
import Hask.Storage
import Hask.Search
import Hask.Error

main :: IO ()
main = do
  cmd <- execParser opts
  case cmd of
    Add addOpts    -> handleAdd addOpts
    List listOpts  -> handleList listOpts
    Search query   -> handleSearch query
    Delete noteIdV -> handleDelete noteIdV

-- Handlers ------------------------------------------------------------------

handleAdd :: AddOpts -> IO ()
handleAdd (AddOpts t rawTags prio) = do
  result <- loadStore notesFile
  case result of
    Left err -> putStrLn (showError (StorageError err))
    Right store -> do
      let nid  = nextId store
          note = Note
            { noteId   = nid
            , title    = t
            , body     = ""
            , tags     = splitTags rawTags
            , priority = prio
            }
          store' = store
            { nextId = nid + 1
            , notes  = notes store ++ [note]
            }
      saveStore notesFile store'
      putStrLn ("Added note " ++ show nid ++ ": " ++ t)

handleList :: ListOpts -> IO ()
handleList (ListOpts maybeTag) = do
  result <- loadStore notesFile
  case result of
    Left err -> putStrLn (showError (StorageError err))
    Right store -> do
      let ns = case maybeTag of
                 Nothing  -> notes store
                 Just tag -> filterByTag tag (notes store)
      if null ns
        then putStrLn "No notes found."
        else mapM_ printNote ns

handleSearch :: String -> IO ()
handleSearch query = do
  result <- loadStore notesFile
  case result of
    Left err -> putStrLn (showError (StorageError err))
    Right store -> do
      let found = searchNotes query (notes store)
      if null found
        then putStrLn ("No notes matching \"" ++ query ++ "\".")
        else mapM_ printNote found

handleDelete :: Int -> IO ()
handleDelete nid = do
  result <- loadStore notesFile
  case result of
    Left err -> putStrLn (showError (StorageError err))
    Right store -> do
      let (matching, remaining) = partition ((== nid) . noteId) (notes store)
      if null matching
        then putStrLn (showError (NoteNotFound nid))
        else do
          let store' = store { notes = remaining }
          saveStore notesFile store'
          putStrLn ("Deleted note " ++ show nid ++ ".")
  where
    partition f xs = (filter f xs, filter (not . f) xs)

-- Helpers -------------------------------------------------------------------

-- | Split a comma-separated string into a list of tags.
splitTags :: String -> [String]
splitTags "" = []
splitTags s  = case break (== ',') s of
  (tag, "")      -> [tag]
  (tag, _ : rest) -> tag : splitTags rest

-- | Print a note in a readable format.
printNote :: Note -> IO ()
printNote n = putStrLn $
  "[" ++ show (noteId n) ++ "] "
  ++ title n
  ++ " (" ++ show (priority n) ++ ")"
  ++ if null (tags n) then ""
     else "  [" ++ joinWith ", " (tags n) ++ "]"

-- | Join a list of strings with a separator.
joinWith :: String -> [String] -> String
joinWith _ []     = ""
joinWith _ [x]    = x
joinWith sep (x:xs) = x ++ sep ++ joinWith sep xs
