module Hask.Search
  ( searchNotes
  , filterByTag
  ) where

import Data.Char (toLower)
import Data.List (isInfixOf)
import Hask.Types

-- | Search notes by a query string. Matches against title, body, and tags.
-- The search is case-insensitive.
searchNotes :: String -> [Note] -> [Note]
searchNotes query = filter (matchesQuery (map toLower query))

matchesQuery :: String -> Note -> Bool
matchesQuery q note =
  q `isInfixOf` map toLower (title note)
  || q `isInfixOf` map toLower (body note)
  || any (\t -> q `isInfixOf` map toLower t) (tags note)

-- | Filter notes that have a specific tag (case-insensitive).
filterByTag :: String -> [Note] -> [Note]
filterByTag tag = filter (hasTag (map toLower tag))
  where
    hasTag t note = any (\nt -> t == map toLower nt) (tags note)
