{-# LANGUAGE OverloadedStrings #-}

module Hask.CLI
  ( Command(..)
  , AddOpts(..)
  , ListOpts(..)
  , commandParser
  ) where

import Data.Text (Text, pack)
import Options.Applicative

import Hask.Types (Priority(..))
import Hask.Export (ExportFormat(..), parseExportFormat)

data Command
  = Add    AddOpts
  | List   ListOpts
  | Search Text
  | Delete Int
  | Export ExportFormat
  deriving (Show)

data AddOpts = AddOpts
  { addTitle    :: Text
  , addBody     :: Text
  , addTags     :: String      -- comma-separated, parsed later
  , addPriority :: Priority
  } deriving (Show)

data ListOpts = ListOpts
  { listTag :: Maybe Text
  } deriving (Show)

-- -------------------------------------------------------------------
-- Top-level parser
-- -------------------------------------------------------------------

commandParser :: Parser Command
commandParser = subparser
  (  command "add"    (info addParser    (progDesc "Add a new note"))
  <> command "list"   (info listParser   (progDesc "List all notes"))
  <> command "search" (info searchParser (progDesc "Search notes"))
  <> command "delete" (info deleteParser (progDesc "Delete a note by ID"))
  <> command "export" (info exportParser (progDesc "Export notes (md, csv, json)"))
  )

-- -------------------------------------------------------------------
-- Subcommand parsers
-- -------------------------------------------------------------------

addParser :: Parser Command
addParser = fmap Add $ AddOpts
  <$> (pack <$> argument str (metavar "TITLE" <> help "Note title"))
  <*> (pack <$> strOption
        (  long "body"
        <> short 'b'
        <> metavar "BODY"
        <> value ""
        <> help "Note body text"
        ))
  <*> strOption
        (  long "tags"
        <> short 't'
        <> metavar "TAGS"
        <> value ""
        <> help "Comma-separated tags"
        )
  <*> option auto
        (  long "priority"
        <> short 'p'
        <> metavar "PRIORITY"
        <> value Medium
        <> help "Priority: Low, Medium, High"
        )

listParser :: Parser Command
listParser = fmap List $ ListOpts
  <$> optional (pack <$> strOption
        (  long "tag"
        <> metavar "TAG"
        <> help "Filter by tag"
        ))

searchParser :: Parser Command
searchParser = Search . pack
  <$> argument str (metavar "QUERY" <> help "Search query")

deleteParser :: Parser Command
deleteParser = Delete
  <$> argument auto (metavar "ID" <> help "Note ID to delete")

exportParser :: Parser Command
exportParser = Export
  <$> option (maybeReader parseExportFormat)
        (  long "format"
        <> short 'f'
        <> metavar "FORMAT"
        <> help "Export format: md, csv, json"
        )
