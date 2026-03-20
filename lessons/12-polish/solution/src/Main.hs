module Main where

import Options.Applicative

import Hask.CLI  (commandParser)
import Hask.App  (runCommand)

main :: IO ()
main = do
    cmd <- execParser opts
    runCommand cmd
  where
    opts = info (commandParser <**> helper)
      (  fullDesc
      <> progDesc "A note-taking CLI app"
      <> header "hask - notes from the command line"
      )
