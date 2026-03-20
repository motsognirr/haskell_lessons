{-# LANGUAGE DeriveGeneric #-}

module Hask.Types
  ( Note(..)
  , Priority(..)
  , NoteStore(..)
  ) where

import GHC.Generics (Generic)
import Data.Aeson   (ToJSON, FromJSON)

-- | Priority levels for notes.
data Priority = Low | Medium | High
  deriving (Show, Read, Eq, Ord, Generic)

instance ToJSON   Priority
instance FromJSON Priority

-- | A single note.
data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Read, Eq, Generic)

instance ToJSON   Note
instance FromJSON Note

-- | Top-level store: wraps metadata and the list of notes.
data NoteStore = NoteStore
  { nextId :: Int
  , notes  :: [Note]
  } deriving (Show, Read, Eq, Generic)

instance ToJSON   NoteStore
instance FromJSON NoteStore
