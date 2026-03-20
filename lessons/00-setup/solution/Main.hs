module Main where

import System.Environment (getArgs)

main :: IO ()
main = do
    args <- getArgs
    case args of
        (name:_) -> putStrLn ("Hello, " ++ name ++ "! Welcome to Haskell.")
        []       -> putStrLn "Hello, World! Welcome to Haskell."
