module Hask.Types
  ( Priority(..)
  , Note(..)
  ) where

data Priority = Low | Medium | High
  deriving (Show, Eq, Ord)

data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Eq)
