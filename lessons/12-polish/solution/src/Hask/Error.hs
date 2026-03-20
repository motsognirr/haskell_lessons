module Hask.Error
  ( HaskError(..)
  , formatError
  ) where

data HaskError
  = NoteNotFound Int
  | ParseError String
  | StorageError String
  | ExportError String
  deriving (Show, Eq)

formatError :: HaskError -> String
formatError (NoteNotFound i)   = "Error: note " ++ show i ++ " not found."
formatError (ParseError msg)   = "Parse error: " ++ msg
formatError (StorageError msg) = "Storage error: " ++ msg
formatError (ExportError msg)  = "Export error: " ++ msg
