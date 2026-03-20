module Hask.Storage
  ( loadNotes
  , saveNotes
  , notesFile
  ) where

import Data.Aeson (eitherDecode, encode)
import qualified Data.ByteString.Lazy as BL
import System.Directory (doesFileExist)

import Hask.Types
import Hask.Error

notesFile :: FilePath
notesFile = "notes.json"

loadNotes :: FilePath -> IO (Either AppError [Note])
loadNotes path = do
  exists <- doesFileExist path
  if not exists
    then return (Right [])
    else do
      bytes <- BL.readFile path
      case eitherDecode bytes of
        Left err    -> return (Left (ParseError err))
        Right notes -> return (Right notes)

saveNotes :: FilePath -> [Note] -> IO (Either AppError ())
saveNotes path notes = do
  BL.writeFile path (encode notes)
  return (Right ())
