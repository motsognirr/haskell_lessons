module Hask.Error
  ( AppError(..)
  , showError
  ) where

data AppError
  = NoteNotFound Int
  | StorageError String
  | ParseError String
  deriving (Show, Eq)

showError :: AppError -> String
showError (NoteNotFound nid) = "Note not found: " ++ show nid
showError (StorageError msg) = "Storage error: " ++ msg
showError (ParseError msg)   = "Parse error: " ++ msg
