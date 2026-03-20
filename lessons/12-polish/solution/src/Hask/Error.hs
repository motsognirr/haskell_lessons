module Hask.Error
  ( HaskError(..)
  , formatError
  ) where

data HaskError
  = NotFound Int
  | ParseError String
  | StorageError String
  | ExportError String
  deriving (Show, Eq)

formatError :: HaskError -> String
formatError (NotFound i)       = "Error: note " ++ show i ++ " not found."
formatError (ParseError msg)   = "Parse error: " ++ msg
formatError (StorageError msg) = "Storage error: " ++ msg
formatError (ExportError msg)  = "Export error: " ++ msg
