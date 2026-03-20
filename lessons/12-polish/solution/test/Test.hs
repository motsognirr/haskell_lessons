{-# LANGUAGE OverloadedStrings #-}

module Main where

import Test.Hspec
import Data.Aeson (encode, decode)
import Data.List (isInfixOf)
import Data.Text (Text)
import qualified Data.Text as T
import System.Directory (doesFileExist, removeFile)

import Hask.Types
import Hask.Search
import Hask.Storage
import Hask.Export

-- -------------------------------------------------------------------
-- Sample data
-- -------------------------------------------------------------------

sampleNotes :: [Note]
sampleNotes =
  [ Note 1 "Learn Haskell"  "Read the Haskell Book" ["haskell", "books"] High
  , Note 2 "Buy groceries"  "Milk, eggs, bread"     ["shopping"]         Low
  , Note 3 "Haskell meetup"  ""                      ["haskell", "event"] Medium
  ]

-- -------------------------------------------------------------------
-- Tests
-- -------------------------------------------------------------------

main :: IO ()
main = hspec $ do

  -- Types / JSON round-trip
  describe "Hask.Types JSON" $ do
    it "round-trips a Priority through JSON" $ do
      decode (encode High)   `shouldBe` Just High
      decode (encode Medium) `shouldBe` Just Medium
      decode (encode Low)    `shouldBe` Just Low

    it "round-trips a Note through JSON" $ do
      let note = Note 1 "Test" "Body" ["a", "b"] Medium
      decode (encode note) `shouldBe` Just note

    it "round-trips a list of notes through JSON" $ do
      decode (encode sampleNotes) `shouldBe` Just sampleNotes

  -- Search
  describe "Hask.Search" $ do
    it "finds notes by title" $ do
      let results = searchNotes "haskell" sampleNotes
      length results `shouldBe` 2

    it "is case-insensitive" $ do
      let results = searchNotes "HASKELL" sampleNotes
      length results `shouldBe` 2

    it "finds notes by tag" $ do
      let results = searchNotes "shopping" sampleNotes
      length results `shouldBe` 1

    it "finds notes by body" $ do
      let results = searchNotes "milk" sampleNotes
      length results `shouldBe` 1

    it "returns empty for no match" $ do
      let results = searchNotes "nonexistent" sampleNotes
      length results `shouldBe` 0

  -- Storage
  describe "Hask.Storage" $ do
    let testFile = "test_notes.json"

    it "saves and loads notes" $ do
      saveNotes testFile sampleNotes
      result <- loadNotes testFile
      result `shouldBe` Right sampleNotes
      removeFile testFile

    it "returns empty list for missing file" $ do
      result <- loadNotes "does_not_exist.json"
      result `shouldBe` Right []

    it "getNextId returns 1 for empty list" $ do
      getNextId [] `shouldBe` 1

    it "getNextId returns max + 1" $ do
      getNextId sampleNotes `shouldBe` 4

  -- Export
  describe "Hask.Export" $ do
    it "exports Markdown containing titles" $ do
      let md = exportNotes Markdown sampleNotes
      "Learn Haskell" `shouldSatisfy` (`isInfixOf` md)
      "Buy groceries" `shouldSatisfy` (`isInfixOf` md)

    it "exports Markdown with priority" $ do
      let md = exportNotes Markdown sampleNotes
      "High" `shouldSatisfy` (`isInfixOf` md)

    it "exports CSV with header" $ do
      let csv = exportNotes CSV sampleNotes
      "id,title,body,tags,priority" `shouldSatisfy` (`isInfixOf` csv)

    it "exports CSV containing titles" $ do
      let csv = exportNotes CSV sampleNotes
      "Learn Haskell" `shouldSatisfy` (`isInfixOf` csv)

    it "exports JSON containing titles" $ do
      let json = exportNotes JSON sampleNotes
      "Learn Haskell" `shouldSatisfy` (`isInfixOf` json)

    it "parseExportFormat parses valid formats" $ do
      parseExportFormat "md"   `shouldBe` Just Markdown
      parseExportFormat "csv"  `shouldBe` Just CSV
      parseExportFormat "json" `shouldBe` Just JSON

    it "parseExportFormat rejects invalid formats" $ do
      parseExportFormat "xml" `shouldBe` Nothing
