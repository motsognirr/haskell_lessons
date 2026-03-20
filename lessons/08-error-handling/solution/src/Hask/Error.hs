module Hask.Error
  ( HaskError(..)
  , formatError
  ) where

data HaskError
  = NoteNotFound Int
  | InvalidCommand String
  | StorageError String
  | ParseError String
  deriving (Show, Eq)

formatError :: HaskError -> String
formatError (NoteNotFound i)      = "Error: note " ++ show i ++ " not found."
formatError (InvalidCommand cmd)  = "Error: unknown command '" ++ cmd ++ "'. Run hask with no arguments for usage."
formatError (StorageError msg)    = "Error: could not access storage -- " ++ msg
formatError (ParseError msg)      = "Error: " ++ msg
