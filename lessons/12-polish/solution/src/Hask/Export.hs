{-# LANGUAGE OverloadedStrings #-}

module Hask.Export
  ( ExportFormat(..)
  , exportNotes
  , parseExportFormat
  ) where

import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BLC
import Data.Text (Text)
import qualified Data.Text as T

import Hask.Types

data ExportFormat = Markdown | CSV | JSON
  deriving (Show, Eq)

-- | Parse a format string into an ExportFormat.
parseExportFormat :: String -> Maybe ExportFormat
parseExportFormat "md"       = Just Markdown
parseExportFormat "markdown" = Just Markdown
parseExportFormat "csv"      = Just CSV
parseExportFormat "json"     = Just JSON
parseExportFormat _          = Nothing

-- | Export notes in the given format, returning a plain String.
exportNotes :: ExportFormat -> [Note] -> String
exportNotes Markdown notes = exportMarkdown notes
exportNotes CSV      notes = exportCSV notes
exportNotes JSON     notes = exportJSON notes

-- -------------------------------------------------------------------
-- Markdown
-- -------------------------------------------------------------------

exportMarkdown :: [Note] -> String
exportMarkdown notes =
    T.unpack $ T.intercalate "\n---\n\n" (map noteToMarkdown notes)

noteToMarkdown :: Note -> Text
noteToMarkdown note = T.unlines parts
  where
    parts = concat
      [ [ "## " <> title note ]
      , if T.null (body note) then [] else [ "", body note ]
      , [ "", "**Priority:** " <> T.pack (show (priority note)) ]
      , if null (tags note) then []
        else [ "**Tags:** " <> T.intercalate ", " (tags note) ]
      ]

-- -------------------------------------------------------------------
-- CSV
-- -------------------------------------------------------------------

exportCSV :: [Note] -> String
exportCSV notes =
    T.unpack $ T.unlines (header : map noteToCSV notes)
  where
    header = "id,title,body,tags,priority"

noteToCSV :: Note -> Text
noteToCSV note = T.intercalate "," fields
  where
    fields =
      [ T.pack (show (noteId note))
      , csvQuote (title note)
      , csvQuote (body note)
      , csvQuote (T.intercalate "," (tags note))
      , csvQuote (T.pack (show (priority note)))
      ]

csvQuote :: Text -> Text
csvQuote t = "\"" <> T.replace "\"" "\"\"" t <> "\""

-- -------------------------------------------------------------------
-- JSON
-- -------------------------------------------------------------------

exportJSON :: [Note] -> String
exportJSON = BLC.unpack . encode
