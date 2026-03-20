{-# LANGUAGE OverloadedStrings #-}

module Hask.Display
  ( colorPutStrLn
  , successMsg
  , errorMsg
  , priorityColor
  , displayNote
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Console.ANSI

import Hask.Types

-- | Map a priority level to an ANSI color.
priorityColor :: Priority -> Color
priorityColor High   = Red
priorityColor Medium = Yellow
priorityColor Low    = Green

-- | Print a line of text in the given color, then reset.
colorPutStrLn :: Color -> String -> IO ()
colorPutStrLn color msg = do
    setSGR [SetColor Foreground Vivid color]
    putStrLn msg
    setSGR [Reset]

-- | Print a success message in green.
successMsg :: String -> IO ()
successMsg = colorPutStrLn Green

-- | Print an error message in red.
errorMsg :: String -> IO ()
errorMsg = colorPutStrLn Red

-- | Pretty-print a single note with colored priority.
displayNote :: Note -> IO ()
displayNote note = do
    -- Print the ID and title
    putStr ("[" ++ show (noteId note) ++ "] ")
    TIO.putStr (title note)

    -- Print priority in its color
    putStr "  ("
    setSGR [SetColor Foreground Vivid (priorityColor (priority note))]
    putStr (show (priority note))
    setSGR [Reset]
    putStrLn ")"

    -- Print body if non-empty
    let b = body note
    if T.null b
      then return ()
      else do
        putStr "    "
        TIO.putStrLn b

    -- Print tags in cyan if any
    let ts = tags note
    if null ts
      then return ()
      else do
        putStr "    "
        setSGR [SetColor Foreground Vivid Cyan]
        TIO.putStrLn (T.intercalate ", " ts)
        setSGR [Reset]
