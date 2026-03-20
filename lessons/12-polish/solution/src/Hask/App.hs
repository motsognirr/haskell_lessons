{-# LANGUAGE OverloadedStrings #-}

module Hask.App
  ( runCommand
  ) where

import Data.Text (Text, pack, unpack)
import qualified Data.Text as T

import Hask.Types
import Hask.CLI
import Hask.Storage
import Hask.Search
import Hask.Export
import Hask.Display

-- | Run a parsed command.
runCommand :: Command -> IO ()
runCommand (Add opts)    = handleAdd opts
runCommand (List opts)   = handleList opts
runCommand (Search q)    = handleSearch q
runCommand (Delete nid)  = handleDelete nid
runCommand (Export fmt)  = handleExport fmt

-- -------------------------------------------------------------------
-- Command handlers
-- -------------------------------------------------------------------

handleAdd :: AddOpts -> IO ()
handleAdd opts = do
    result <- loadNotes notesFile
    case result of
      Left err -> errorMsg ("Error: " ++ err)
      Right notes -> do
        let newId   = getNextId notes
            ts      = splitTags (addTags opts)
            newNote = Note newId (addTitle opts) (addBody opts) ts (addPriority opts)
            updated = notes ++ [newNote]
        saveNotes notesFile updated
        successMsg ("Added: " ++ unpack (addTitle opts))

handleList :: ListOpts -> IO ()
handleList (ListOpts maybeTag) = do
    result <- loadNotes notesFile
    case result of
      Left err -> errorMsg ("Error: " ++ err)
      Right notes -> do
        let filtered = case maybeTag of
              Nothing  -> notes
              Just tag -> filter (elem tag . tags) notes
        if null filtered
          then putStrLn "No notes yet."
          else mapM_ displayNote filtered

handleSearch :: Text -> IO ()
handleSearch query = do
    result <- loadNotes notesFile
    case result of
      Left err -> errorMsg ("Error: " ++ err)
      Right notes -> do
        let results = searchNotes query notes
        if null results
          then putStrLn "No notes found."
          else mapM_ displayNote results

handleDelete :: Int -> IO ()
handleDelete nid = do
    result <- loadNotes notesFile
    case result of
      Left err -> errorMsg ("Error: " ++ err)
      Right notes -> do
        let remaining = filter (\n -> noteId n /= nid) notes
        if length remaining == length notes
          then errorMsg ("Error: note " ++ show nid ++ " not found.")
          else do
            saveNotes notesFile remaining
            successMsg ("Deleted note " ++ show nid)

handleExport :: ExportFormat -> IO ()
handleExport fmt = do
    result <- loadNotes notesFile
    case result of
      Left err    -> errorMsg ("Error: " ++ err)
      Right notes -> putStrLn (exportNotes fmt notes)

-- -------------------------------------------------------------------
-- Helpers
-- -------------------------------------------------------------------

splitTags :: String -> [Text]
splitTags "" = []
splitTags s  = map (T.strip . pack) (splitOn ',' s)

splitOn :: Char -> String -> [String]
splitOn _ "" = []
splitOn c s  = case break (== c) s of
    (chunk, "")      -> [chunk]
    (chunk, _ : rest) -> chunk : splitOn c rest
