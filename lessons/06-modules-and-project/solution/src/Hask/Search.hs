module Hask.Search
  ( searchNotes
  ) where

import Data.Char (toLower)
import Data.List (isInfixOf)
import Hask.Types

searchNotes :: String -> [Note] -> [Note]
searchNotes query = filter (matchesQuery (map toLower query))

matchesQuery :: String -> Note -> Bool
matchesQuery q note =
  q `isInfixOf` map toLower (title note)
  || q `isInfixOf` map toLower (body note)
  || any (\t -> q `isInfixOf` map toLower t) (tags note)
