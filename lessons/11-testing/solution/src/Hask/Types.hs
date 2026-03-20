{-# LANGUAGE DeriveGeneric #-}

module Hask.Types
  ( Priority(..)
  , Note(..)
  ) where

import GHC.Generics (Generic)
import Data.Aeson   (ToJSON, FromJSON)

data Priority = Low | Medium | High
  deriving (Show, Read, Eq, Ord, Generic)

instance ToJSON   Priority
instance FromJSON Priority

data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Read, Eq, Generic)

instance ToJSON   Note
instance FromJSON Note
