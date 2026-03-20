module Hask.Error
  ( HaskError(..)
  , formatError
  ) where

-- | Application-level errors.
data HaskError
  = NoteNotFound Int
  | StorageError String
  | ParseError String
  deriving (Show, Eq)

-- | Render an error as a user-friendly message.
formatError :: HaskError -> String
formatError (NoteNotFound nid) = "Error: note " ++ show nid ++ " not found."
formatError (StorageError msg) = "Error: could not access storage -- " ++ msg
formatError (ParseError msg)   = "Error: " ++ msg
