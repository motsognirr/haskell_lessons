module Hask.App
  ( runApp
  ) where

import Data.Char (toLower)

import Hask.Types
import Hask.Search
import Hask.Storage
import Hask.Error
import Hask.CLI

runApp :: IO ()
runApp = do
  cmd <- runCLI
  case cmd of
    Add t b tgs p -> doAdd t b tgs p
    List mtag     -> doList mtag
    Search q      -> doSearch q
    Delete nid    -> doDelete nid

doAdd :: String -> String -> [String] -> String -> IO ()
doAdd t b tgs p = do
  result <- loadNotes notesFile
  case result of
    Left err -> putStrLn (formatError err)
    Right notes -> do
      let nid = if null notes then 1 else maximum (map noteId notes) + 1
          pri = parsePriority p
          note = Note nid t b tgs pri
      saveResult <- saveNotes notesFile (notes ++ [note])
      case saveResult of
        Left err -> putStrLn (formatError err)
        Right () -> putStrLn ("Added note " ++ show nid ++ ": " ++ t)

doList :: Maybe String -> IO ()
doList mtag = do
  result <- loadNotes notesFile
  case result of
    Left err -> putStrLn (formatError err)
    Right notes -> do
      let filtered = case mtag of
            Nothing  -> notes
            Just tag -> filterByTag tag notes
      if null filtered
        then putStrLn "No notes found."
        else mapM_ printNote filtered

doSearch :: String -> IO ()
doSearch q = do
  result <- loadNotes notesFile
  case result of
    Left err -> putStrLn (formatError err)
    Right notes -> do
      let results = searchNotes q notes
      if null results
        then putStrLn "No notes found."
        else mapM_ printNote results

doDelete :: Int -> IO ()
doDelete nid = do
  result <- loadNotes notesFile
  case result of
    Left err -> putStrLn (formatError err)
    Right notes -> do
      let remaining = filter (\n -> noteId n /= nid) notes
      if length remaining == length notes
        then putStrLn (formatError (NoteNotFound nid))
        else do
          saveResult <- saveNotes notesFile remaining
          case saveResult of
            Left err -> putStrLn (formatError err)
            Right () -> putStrLn ("Deleted note " ++ show nid)

printNote :: Note -> IO ()
printNote n = putStrLn $
  "[" ++ show (noteId n) ++ "] "
  ++ title n
  ++ " (" ++ show (priority n) ++ ")"
  ++ if null (tags n) then "" else " [" ++ unwords (tags n) ++ "]"

parsePriority :: String -> Priority
parsePriority s = case map toLower s of
  "high" -> High
  "low"  -> Low
  _      -> Medium
