module Hask.Storage
  ( saveNotes
  , loadNotes
  , getNextId
  ) where

import Hask.Types
import System.Directory (doesFileExist)

saveNotes :: FilePath -> [Note] -> IO ()
saveNotes path notes = writeFile path (show notes)

loadNotes :: FilePath -> IO [Note]
loadNotes path = do
    exists <- doesFileExist path
    if exists
      then do
        contents <- readFile path
        let notes = read contents :: [Note]
        return notes
      else return []

getNextId :: [Note] -> Int
getNextId [] = 1
getNextId notes = maximum (map noteId notes) + 1
