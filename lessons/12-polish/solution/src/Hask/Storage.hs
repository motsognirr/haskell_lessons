{-# LANGUAGE OverloadedStrings #-}

module Hask.Storage
  ( saveNotes
  , loadNotes
  , getNextId
  , notesFile
  ) where

import Data.Aeson (eitherDecode, encodeFile)
import qualified Data.ByteString.Lazy as BL
import System.Directory (doesFileExist)

import Hask.Types

notesFile :: FilePath
notesFile = "notes.json"

saveNotes :: FilePath -> [Note] -> IO ()
saveNotes = encodeFile

loadNotes :: FilePath -> IO (Either String [Note])
loadNotes path = do
    exists <- doesFileExist path
    if not exists
      then return (Right [])
      else do
        bytes <- BL.readFile path
        return (eitherDecode bytes)

getNextId :: [Note] -> Int
getNextId [] = 1
getNextId notes = maximum (map noteId notes) + 1
