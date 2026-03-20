{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Hask.Types
  ( Priority(..)
  , Note(..)
  ) where

import Data.Aeson   (ToJSON, FromJSON)
import Data.Text    (Text)
import GHC.Generics (Generic)

data Priority = Low | Medium | High
  deriving (Show, Read, Eq, Ord, Generic)

instance ToJSON   Priority
instance FromJSON Priority

data Note = Note
  { noteId   :: Int
  , title    :: Text
  , body     :: Text
  , tags     :: [Text]
  , priority :: Priority
  } deriving (Show, Read, Eq, Generic)

instance ToJSON   Note
instance FromJSON Note
