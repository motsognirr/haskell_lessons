{-# LANGUAGE OverloadedStrings #-}

module Hask.Search
  ( searchNotes
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import Hask.Types

searchNotes :: Text -> [Note] -> [Note]
searchNotes query = filter (matchesQuery (T.toLower query))

matchesQuery :: Text -> Note -> Bool
matchesQuery q note =
     q `T.isInfixOf` T.toLower (title note)
  || q `T.isInfixOf` T.toLower (body note)
  || any (\t -> q `T.isInfixOf` T.toLower t) (tags note)
