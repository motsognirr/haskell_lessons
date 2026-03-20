module Main where

import System.Environment (getArgs)
import Hask.Types
import Hask.Search
import Hask.Storage

notesFile :: FilePath
notesFile = "notes.dat"

main :: IO ()
main = do
    args <- getArgs
    case args of
      ("add":titleStr:_) -> do
          notes <- loadNotes notesFile
          let newId   = getNextId notes
              newNote = Note newId titleStr "" [] Medium
              updated = notes ++ [newNote]
          saveNotes notesFile updated
          putStrLn ("Added: " ++ titleStr)

      ["list"] -> do
          notes <- loadNotes notesFile
          if null notes
            then putStrLn "No notes yet."
            else mapM_ (putStrLn . title) notes

      ("search":query:_) -> do
          notes <- loadNotes notesFile
          let results = searchNotes query notes
          if null results
            then putStrLn "No notes found."
            else mapM_ (putStrLn . title) results

      _ -> putStrLn "Usage: hask <add|list|search> [args]"
