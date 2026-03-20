{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Aeson (encode, decode)
import Data.List (isInfixOf)
import Test.Tasty
import Test.Tasty.HUnit

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
main = defaultMain $ testGroup "Hask Tests"
  [ typesTests
  , searchTests
  , storageTests
  , exportTests
  ]

-- Types / JSON round-trip
typesTests :: TestTree
typesTests = testGroup "Hask.Types JSON"
  [ testCase "round-trips a Priority through JSON" $ do
      decode (encode High)   @?= Just High
      decode (encode Medium) @?= Just Medium
      decode (encode Low)    @?= Just Low

  , testCase "round-trips a Note through JSON" $ do
      let note = Note 1 "Test" "Body" ["a", "b"] Medium
      decode (encode note) @?= Just note

  , testCase "round-trips a list of notes through JSON" $
      decode (encode sampleNotes) @?= Just sampleNotes
  ]

-- Search
searchTests :: TestTree
searchTests = testGroup "Hask.Search"
  [ testCase "finds notes by title" $ do
      let results = searchNotes "haskell" sampleNotes
      length results @?= 2

  , testCase "is case-insensitive" $ do
      let results = searchNotes "HASKELL" sampleNotes
      length results @?= 2

  , testCase "finds notes by tag" $ do
      let results = searchNotes "shopping" sampleNotes
      length results @?= 1

  , testCase "finds notes by body" $ do
      let results = searchNotes "milk" sampleNotes
      length results @?= 1

  , testCase "returns empty for no match" $ do
      let results = searchNotes "nonexistent" sampleNotes
      length results @?= 0
  ]

-- Storage
storageTests :: TestTree
storageTests = testGroup "Hask.Storage"
  [ testCase "returns empty list for missing file" $ do
      result <- loadNotes "does_not_exist.json"
      result @?= Right []

  , testCase "getNextId returns 1 for empty list" $
      getNextId [] @?= 1

  , testCase "getNextId returns max + 1" $
      getNextId sampleNotes @?= 4
  ]

-- Export
exportTests :: TestTree
exportTests = testGroup "Hask.Export"
  [ testCase "exports Markdown containing titles" $ do
      let md = exportNotes Markdown sampleNotes
      assertBool "Learn Haskell in markdown" ("Learn Haskell" `isInfixOf` md)
      assertBool "Buy groceries in markdown" ("Buy groceries" `isInfixOf` md)

  , testCase "exports Markdown with priority" $ do
      let md = exportNotes Markdown sampleNotes
      assertBool "High priority in markdown" ("High" `isInfixOf` md)

  , testCase "exports CSV with header" $ do
      let csv = exportNotes CSV sampleNotes
      assertBool "CSV header" ("id,title,body,tags,priority" `isInfixOf` csv)

  , testCase "exports CSV containing titles" $ do
      let csv = exportNotes CSV sampleNotes
      assertBool "Learn Haskell in csv" ("Learn Haskell" `isInfixOf` csv)

  , testCase "exports JSON containing titles" $ do
      let json = exportNotes JSON sampleNotes
      assertBool "Learn Haskell in json" ("Learn Haskell" `isInfixOf` json)

  , testCase "parseExportFormat parses valid formats" $ do
      parseExportFormat "md"   @?= Just Markdown
      parseExportFormat "csv"  @?= Just CSV
      parseExportFormat "json" @?= Just JSON

  , testCase "parseExportFormat rejects invalid formats" $
      parseExportFormat "xml" @?= Nothing
  ]
