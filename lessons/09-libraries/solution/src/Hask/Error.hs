module Hask.Error
  ( HaskError(..)
  , showError
  ) where

-- | Application-level errors.
data HaskError
  = NoteNotFound Int
  | StorageError String
  | ParseError String
  deriving (Show, Eq)

-- | Render an error as a user-friendly message.
showError :: HaskError -> String
showError (NoteNotFound nid) = "Error: note with id " ++ show nid ++ " not found."
showError (StorageError msg) = "Storage error: " ++ msg
showError (ParseError msg)   = "Parse error: " ++ msg
