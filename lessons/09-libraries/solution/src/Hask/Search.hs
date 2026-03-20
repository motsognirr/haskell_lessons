module Hask.Search
  ( searchNotes
  , filterByTag
  ) where

import Data.Char (toLower)
import Hask.Types (Note(..))

-- | Search notes by a query string.  Matches against title, body, and tags
-- (case-insensitive substring match).
searchNotes :: String -> [Note] -> [Note]
searchNotes query = filter (matchesNote (map toLower query))
  where
    matchesNote q note =
      q `isInfixOfCI` title note
        || q `isInfixOfCI` body note
        || any (q `isInfixOfCI`) (tags note)

    isInfixOfCI needle haystack = needle `isInfixOf'` map toLower haystack

    isInfixOf' [] _          = True
    isInfixOf' _  []         = False
    isInfixOf' xs ys
      | take (length xs) ys == xs = True
      | otherwise                 = isInfixOf' xs (drop 1 ys)

-- | Filter notes that contain a specific tag.
filterByTag :: String -> [Note] -> [Note]
filterByTag tag = filter (elem tag . tags)
