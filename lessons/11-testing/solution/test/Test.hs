module Main where

import Data.Char (toLower, toUpper)
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck
import Test.QuickCheck

import Hask.Types
import Hask.Search

-- ---------------------------------------------------------------------------
-- Arbitrary instances for our types
-- ---------------------------------------------------------------------------

instance Arbitrary Priority where
  arbitrary = elements [Low, Medium, High]

instance Arbitrary Note where
  arbitrary = Note
    <$> arbitrary
    <*> arbitrary
    <*> arbitrary
    <*> listOf arbitrary
    <*> arbitrary

-- ---------------------------------------------------------------------------
-- Sample data for unit tests
-- ---------------------------------------------------------------------------

sampleNotes :: [Note]
sampleNotes =
  [ Note 1 "Learn Haskell" "Study types, functions, and monads" ["haskell", "programming"] High
  , Note 2 "Buy groceries" "Milk, eggs, bread" ["shopping", "errands"] Low
  , Note 3 "Haskell project" "Build a CLI note manager in Haskell" ["haskell", "project"] Medium
  , Note 4 "Read a book" "Finish reading Dune" ["reading", "hobby"] Low
  ]

-- ---------------------------------------------------------------------------
-- Test tree
-- ---------------------------------------------------------------------------

main :: IO ()
main = defaultMain $ testGroup "Hask Tests"
  [ unitTests
  , propertyTests
  ]

-- ---------------------------------------------------------------------------
-- Unit tests
-- ---------------------------------------------------------------------------

unitTests :: TestTree
unitTests = testGroup "Unit Tests"
  [ testCase "searchNotes finds matching notes" $ do
      let results = searchNotes "haskell" sampleNotes
      length results @?= 2
      map noteId results @?= [1, 3]

  , testCase "searchNotes returns empty for non-matching query" $ do
      let results = searchNotes "zzzznotfound" sampleNotes
      results @?= []

  , testCase "searchNotes is case-insensitive" $ do
      let upper = searchNotes "HASKELL" sampleNotes
          lower = searchNotes "haskell" sampleNotes
      upper @?= lower

  , testCase "filterByTag finds notes with given tag" $ do
      let results = filterByTag "haskell" sampleNotes
      length results @?= 2
      map noteId results @?= [1, 3]

  , testCase "filterByTag returns empty for unknown tag" $ do
      let results = filterByTag "nonexistent" sampleNotes
      results @?= []

  , testCase "searchNotes matches in body" $ do
      let results = searchNotes "milk" sampleNotes
      length results @?= 1
      noteId (head results) @?= 2

  , testCase "searchNotes matches in tags" $ do
      let results = searchNotes "hobby" sampleNotes
      length results @?= 1
      noteId (head results) @?= 4
  ]

-- ---------------------------------------------------------------------------
-- Property tests
-- ---------------------------------------------------------------------------

propertyTests :: TestTree
propertyTests = testGroup "Property Tests"
  [ testProperty "empty query returns all notes" $
      \notes -> searchNotes "" notes == (notes :: [Note])

  , testProperty "search is case-insensitive for any query" $
      \notes query ->
        searchNotes (map toUpper query) (notes :: [Note])
        == searchNotes (map toLower query) notes

  , testProperty "search results are a subset of input" $
      \notes query ->
        let results = searchNotes query (notes :: [Note])
        in all (`elem` notes) results

  , testProperty "number of results never exceeds input size" $
      \notes query ->
        length (searchNotes query (notes :: [Note])) <= length notes

  , testProperty "filterByTag results all have the tag (lowered)" $
      \notes ->
        forAll (elements ["a", "b", "c", "test"]) $ \tag ->
          let results = filterByTag tag (notes :: [Note])
          in all (\n -> map toLower tag `elem` map (map toLower) (tags n)) results
  ]
