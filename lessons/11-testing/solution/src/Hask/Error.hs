module Hask.Error
  ( HaskError(..)
  , formatError
  ) where

data HaskError
  = NoteNotFound Int
  | StorageError String
  | ParseError String
  deriving (Show, Eq)

formatError :: HaskError -> String
formatError (NoteNotFound nid) = "Error: note " ++ show nid ++ " not found."
formatError (StorageError msg) = "Error: could not access storage -- " ++ msg
formatError (ParseError msg)   = "Error: " ++ msg
