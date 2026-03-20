module Main where

import System.Environment (getArgs)
import Hask.Types
import Hask.Search

sampleNotes :: [Note]
sampleNotes =
  [ Note 1 "Learn Haskell" "Study types, functions, and monads" ["haskell", "programming"] High
  , Note 2 "Buy groceries" "Milk, eggs, bread" ["shopping", "errands"] Low
  , Note 3 "Haskell project" "Build a CLI note manager in haskell" ["haskell", "project"] Medium
  ]

main :: IO ()
main = do
    args <- getArgs
    case args of
      ("search":query:_) -> do
        let results = searchNotes query sampleNotes
        if null results
          then putStrLn "No notes found."
          else mapM_ (putStrLn . title) results
      _ -> putStrLn "Usage: hask search <query>"
