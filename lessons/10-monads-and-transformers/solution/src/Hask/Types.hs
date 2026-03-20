{-# LANGUAGE DeriveGeneric #-}

module Hask.Types
  ( Priority(..)
  , Note(..)
  ) where

import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics (Generic)

data Priority = Low | Medium | High
  deriving (Show, Eq, Ord, Read, Generic)

instance ToJSON Priority
instance FromJSON Priority

data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Eq, Read, Generic)

instance ToJSON Note
instance FromJSON Note
