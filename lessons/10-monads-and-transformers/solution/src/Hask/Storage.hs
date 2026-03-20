module Hask.Storage
  ( loadNotes
  , saveNotes
  , addNote
  , listNotes
  , deleteNote
  , searchNotesCmd
  ) where

import Control.Monad (when)
import Control.Monad.Except (throwError)
import Control.Monad.Reader (asks)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (eitherDecode, encode)
import qualified Data.ByteString.Lazy as BS
import System.Directory (doesFileExist)

import Hask.Types
import Hask.Error (HaskError(..))
import Hask.App (AppConfig(..), App)
import Hask.Search (searchNotes)

-- | Load notes from a JSON file. Returns an empty list if the file
--   does not exist. Throws a ParseError if the file cannot be decoded.
loadNotes :: FilePath -> App [Note]
loadNotes path = do
    exists <- liftIO $ doesFileExist path
    if not exists
      then return []
      else do
        contents <- liftIO $ BS.readFile path
        case eitherDecode contents of
          Left msg    -> throwError (ParseError msg)
          Right notes -> return notes

-- | Save notes to a JSON file.
saveNotes :: FilePath -> [Note] -> App ()
saveNotes path notes = liftIO $ BS.writeFile path (encode notes)

-- | Add a new note with the given title.
addNote :: String -> App ()
addNote noteTitle = do
    path  <- asks notesFile
    notes <- loadNotes path
    let newId = if null notes then 1 else maximum (map noteId notes) + 1
        note  = Note newId noteTitle "" [] Medium
    saveNotes path (notes ++ [note])
    liftIO $ putStrLn $ "Added note " ++ show newId ++ ": " ++ noteTitle

-- | List all notes.
listNotes :: App ()
listNotes = do
    path  <- asks notesFile
    notes <- loadNotes path
    if null notes
      then liftIO $ putStrLn "No notes found."
      else liftIO $ mapM_ printNote notes

-- | Delete a note by id.
deleteNote :: Int -> App ()
deleteNote nid = do
    path  <- asks notesFile
    notes <- loadNotes path
    let found = any (\n -> noteId n == nid) notes
    if not found
      then throwError (NoteNotFound nid)
      else do
        let remaining = filter (\n -> noteId n /= nid) notes
        saveNotes path remaining
        liftIO $ putStrLn $ "Deleted note " ++ show nid ++ "."

-- | Search notes by a query string and print results.
searchNotesCmd :: String -> App ()
searchNotesCmd query = do
    path  <- asks notesFile
    notes <- loadNotes path
    let results = searchNotes query notes
    if null results
      then liftIO $ putStrLn "No notes found."
      else liftIO $ mapM_ printNote results

-- | Pretty-print a single note.
printNote :: Note -> IO ()
printNote note =
    putStrLn $ "[" ++ show (noteId note) ++ "] "
            ++ title note
            ++ prio
  where
    prio = case priority note of
      High   -> " (!)"
      Medium -> ""
      Low    -> " (~)"
