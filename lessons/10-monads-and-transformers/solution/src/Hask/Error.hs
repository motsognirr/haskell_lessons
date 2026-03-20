module Hask.Error
  ( HaskError(..)
  , renderError
  ) where

data HaskError
  = NoteNotFound Int
  | ParseError String
  | IOError String
  deriving (Show, Eq)

renderError :: HaskError -> String
renderError (NoteNotFound nid) = "Note with id " ++ show nid ++ " not found"
renderError (ParseError msg)   = "Failed to parse notes file: " ++ msg
renderError (IOError msg)      = "IO error: " ++ msg
