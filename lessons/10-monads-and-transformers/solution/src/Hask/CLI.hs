module Hask.CLI
  ( Options(..)
  , Command(..)
  , optsInfo
  ) where

import Options.Applicative

data Command
  = Add String
  | List
  | Delete Int
  | Search String
  deriving (Show)

data Options = Options
  { optCommand :: Command
  , optFile    :: FilePath
  } deriving (Show)

commandParser :: Parser Command
commandParser = subparser
  ( command "add" (info addParser (progDesc "Add a new note"))
 <> command "list" (info (pure List) (progDesc "List all notes"))
 <> command "delete" (info deleteParser (progDesc "Delete a note by id"))
 <> command "search" (info searchParser (progDesc "Search notes"))
  )

addParser :: Parser Command
addParser = Add <$> argument str (metavar "TITLE" <> help "Title of the note")

deleteParser :: Parser Command
deleteParser = Delete <$> argument auto (metavar "ID" <> help "Note id to delete")

searchParser :: Parser Command
searchParser = Search <$> argument str (metavar "QUERY" <> help "Search query")

optionsParser :: Parser Options
optionsParser = Options
    <$> commandParser
    <*> strOption
          ( long "file"
         <> short 'f'
         <> metavar "FILE"
         <> value "notes.json"
         <> help "Path to the notes file"
          )

optsInfo :: ParserInfo Options
optsInfo = info (optionsParser <**> helper)
  ( fullDesc
 <> progDesc "hask - A CLI note manager"
 <> header "hask - manage your notes from the command line"
  )
