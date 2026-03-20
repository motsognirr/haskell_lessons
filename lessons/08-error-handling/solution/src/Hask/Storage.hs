module Hask.Storage
  ( loadNotes
  , saveNotes
  , addNote
  , deleteNote
  , notesFile
  ) where

import System.Directory (doesFileExist)
import Hask.Types
import Hask.Error

notesFile :: FilePath
notesFile = "notes.dat"

loadNotes :: IO (Either HaskError [Note])
loadNotes = do
  exists <- doesFileExist notesFile
  if not exists
    then return (Right [])
    else do
      contents <- readFile notesFile
      let parsed = reads contents :: [([Note], String)]
      case parsed of
        [(notes, _)] -> return (Right notes)
        _            -> return (Left (ParseError ("Could not parse " ++ notesFile)))

saveNotes :: [Note] -> IO ()
saveNotes notes = writeFile notesFile (show notes)

nextId :: [Note] -> Int
nextId [] = 1
nextId ns = maximum (map noteId ns) + 1

addNote :: String -> IO (Either HaskError Note)
addNote text = do
  result <- loadNotes
  case result of
    Left err -> return (Left err)
    Right notes -> do
      let newNote = Note (nextId notes) text "" [] Medium
      let updated = notes ++ [newNote]
      -- Force evaluation of the old contents before writing
      seq (length (show notes)) (return ())
      saveNotes updated
      return (Right newNote)

deleteNote :: Int -> IO (Either HaskError ())
deleteNote noteIdToDelete = do
  result <- loadNotes
  case result of
    Left err -> return (Left err)
    Right notes -> do
      let remaining = filter (\n -> noteId n /= noteIdToDelete) notes
      if length remaining == length notes
        then return (Left (NoteNotFound noteIdToDelete))
        else do
          seq (length (show notes)) (return ())
          saveNotes remaining
          return (Right ())
