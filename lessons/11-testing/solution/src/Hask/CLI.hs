module Hask.CLI
  ( Command(..)
  , runCLI
  ) where

import Options.Applicative

data Command
  = Add String String [String] String
  | List (Maybe String)
  | Search String
  | Delete Int
  deriving (Show, Eq)

runCLI :: IO Command
runCLI = execParser opts
  where
    opts = info (commandParser <**> helper)
      (  fullDesc
      <> progDesc "A note-taking app"
      <> header "hask - notes from the command line"
      )

commandParser :: Parser Command
commandParser = subparser
  (  command "add"    (info addParser    (progDesc "Add a new note"))
  <> command "list"   (info listParser   (progDesc "List all notes"))
  <> command "search" (info searchParser (progDesc "Search notes"))
  <> command "delete" (info deleteParser (progDesc "Delete a note"))
  )

addParser :: Parser Command
addParser = Add
  <$> argument str (metavar "TITLE" <> help "Note title")
  <*> strOption (long "body" <> short 'b' <> metavar "BODY" <> value "" <> help "Note body")
  <*> many (strOption (long "tag" <> short 't' <> metavar "TAG" <> help "Add a tag"))
  <*> strOption (long "priority" <> short 'p' <> metavar "PRIORITY" <> value "medium" <> help "Priority: low, medium, high")

listParser :: Parser Command
listParser = List
  <$> optional (strOption (long "tag" <> short 't' <> metavar "TAG" <> help "Filter by tag"))

searchParser :: Parser Command
searchParser = Search
  <$> argument str (metavar "QUERY" <> help "Search query")

deleteParser :: Parser Command
deleteParser = Delete
  <$> argument auto (metavar "ID" <> help "Note ID to delete")
