module Main where

import System.Exit (exitFailure)
import Options.Applicative (execParser)

import Hask.App (AppConfig(..), App, runApp)
import Hask.CLI (Options(..), Command(..), optsInfo)
import Hask.Error (renderError)
import Hask.Storage (addNote, listNotes, deleteNote, searchNotesCmd)

-- | Map a CLI command to the corresponding App action.
dispatch :: Command -> App ()
dispatch (Add noteTitle) = addNote noteTitle
dispatch List            = listNotes
dispatch (Delete nid)    = deleteNote nid
dispatch (Search query)  = searchNotesCmd query

main :: IO ()
main = do
    opts <- execParser optsInfo
    let config = AppConfig
          { notesFile = optFile opts
          , verbose   = False
          }
    result <- runApp config (dispatch (optCommand opts))
    case result of
      Left err -> do
        putStrLn $ "Error: " ++ renderError err
        exitFailure
      Right _ ->
        return ()
