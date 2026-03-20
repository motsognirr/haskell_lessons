module Hask.CLI
  ( Command(..)
  , AddOpts(..)
  , ListOpts(..)
  , commandParser
  , opts
  ) where

import Options.Applicative
import Hask.Types (Priority(..))

-- | Top-level commands supported by hask.
data Command
  = Add    AddOpts
  | List   ListOpts
  | Search String
  | Delete Int
  deriving (Show)

-- | Options for the "add" subcommand.
data AddOpts = AddOpts
  { addTitle    :: String
  , addTags     :: String    -- comma-separated
  , addPriority :: Priority
  } deriving (Show)

-- | Options for the "list" subcommand.
data ListOpts = ListOpts
  { listTag :: Maybe String
  } deriving (Show)

-- | Full parser info, ready for 'execParser'.
opts :: ParserInfo Command
opts = info (commandParser <**> helper)
  (  fullDesc
  <> progDesc "A note-taking CLI app"
  <> header "hask - notes from the command line"
  )

-- | Top-level command parser with subcommands.
commandParser :: Parser Command
commandParser = subparser
  (  command "add"    (info addParser    (progDesc "Add a new note"))
  <> command "list"   (info listParser   (progDesc "List notes"))
  <> command "search" (info searchParser (progDesc "Search notes"))
  <> command "delete" (info deleteParser (progDesc "Delete a note by id"))
  )

-- Subcommand parsers --------------------------------------------------------

addParser :: Parser Command
addParser = Add <$> addOptsParser

addOptsParser :: Parser AddOpts
addOptsParser = AddOpts
  <$> argument str
      (  metavar "TITLE"
      <> help "Title of the note"
      )
  <*> strOption
      (  long "tags"
      <> metavar "TAGS"
      <> value ""
      <> help "Comma-separated tags (e.g. \"haskell,fp\")"
      )
  <*> option auto
      (  long "priority"
      <> metavar "PRIORITY"
      <> value Medium
      <> help "Priority: Low, Medium, or High (default: Medium)"
      )

listParser :: Parser Command
listParser = List <$> listOptsParser

listOptsParser :: Parser ListOpts
listOptsParser = ListOpts
  <$> optional (strOption
      (  long "tag"
      <> metavar "TAG"
      <> help "Filter notes by tag"
      ))

searchParser :: Parser Command
searchParser = Search
  <$> argument str
      (  metavar "QUERY"
      <> help "Search query"
      )

deleteParser :: Parser Command
deleteParser = Delete
  <$> argument auto
      (  metavar "ID"
      <> help "ID of the note to delete"
      )
