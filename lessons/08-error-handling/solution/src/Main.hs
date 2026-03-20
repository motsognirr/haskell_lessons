module Main where

import System.Environment (getArgs)
import Hask.Types
import Hask.Search
import Hask.Storage
import Hask.Error

main :: IO ()
main = do
    args <- getArgs
    case args of
      ["add", text]      -> doAdd text
      ["list"]           -> doList
      ["search", query]  -> doSearch query
      ["delete", rawId]  -> doDelete rawId
      (cmd:_)            -> do
                              putStrLn (formatError (InvalidCommand cmd))
                              printUsage
      []                 -> printUsage

printUsage :: IO ()
printUsage = do
    putStrLn "Usage: hask <command> [arguments]"
    putStrLn ""
    putStrLn "Commands:"
    putStrLn "  add <text>       Add a new note"
    putStrLn "  list             List all notes"
    putStrLn "  search <query>   Search notes"
    putStrLn "  delete <id>      Delete a note by ID"

doAdd :: String -> IO ()
doAdd text = do
    result <- addNote text
    case result of
      Left err   -> putStrLn (formatError err)
      Right note -> putStrLn ("Added note " ++ show (noteId note) ++ ": " ++ title note)

doList :: IO ()
doList = do
    result <- loadNotes
    case result of
      Left err    -> putStrLn (formatError err)
      Right notes ->
        if null notes
          then putStrLn "No notes."
          else mapM_ printNote notes

printNote :: Note -> IO ()
printNote note =
    putStrLn (show (noteId note) ++ ". " ++ title note)

doSearch :: String -> IO ()
doSearch query = do
    result <- loadNotes
    case result of
      Left err    -> putStrLn (formatError err)
      Right notes -> do
        let matches = searchNotes query notes
        if null matches
          then putStrLn "No notes found."
          else mapM_ printNote matches

doDelete :: String -> IO ()
doDelete rawId =
    case reads rawId :: [(Int, String)] of
      [(i, "")] -> do
        result <- deleteNote i
        case result of
          Left err -> putStrLn (formatError err)
          Right _  -> putStrLn ("Deleted note " ++ show i ++ ".")
      _ -> putStrLn (formatError (ParseError ("'" ++ rawId ++ "' is not a valid note ID.")))
