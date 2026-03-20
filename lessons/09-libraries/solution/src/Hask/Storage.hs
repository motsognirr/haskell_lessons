module Hask.Storage
  ( notesFile
  , loadStore
  , saveStore
  ) where

import Data.Aeson              (eitherDecode, encode)
import qualified Data.ByteString.Lazy as BL
import System.Directory        (doesFileExist)

import Hask.Types (NoteStore(..))

-- | Default path for the JSON notes file.
notesFile :: FilePath
notesFile = "notes.json"

-- | Load the note store from disk.  Returns an empty store if the file
-- does not exist.
loadStore :: FilePath -> IO (Either String NoteStore)
loadStore path = do
  exists <- doesFileExist path
  if not exists
    then return (Right emptyStore)
    else do
      bytes <- BL.readFile path
      return (eitherDecode bytes)

-- | Save the note store to disk as JSON.
saveStore :: FilePath -> NoteStore -> IO ()
saveStore path store = BL.writeFile path (encode store)

-- | A fresh, empty store.
emptyStore :: NoteStore
emptyStore = NoteStore { nextId = 1, notes = [] }
