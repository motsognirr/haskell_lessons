module Hask.Search
  ( searchNotes
  , filterByTag
  ) where

import Data.Char (toLower)
import Data.List (isInfixOf)
import Hask.Types (Note(..))

-- | Search notes by a query string.  Matches against title, body, and tags
-- (case-insensitive substring match).
searchNotes :: String -> [Note] -> [Note]
searchNotes query = filter (matchesNote (map toLower query))
  where
    matchesNote q note =
      q `isInfixOf` map toLower (title note)
        || q `isInfixOf` map toLower (body note)
        || any (q `isInfixOf`) (map (map toLower) (tags note))

-- | Filter notes that contain a specific tag.
filterByTag :: String -> [Note] -> [Note]
filterByTag tag = filter (elem tag . tags)
