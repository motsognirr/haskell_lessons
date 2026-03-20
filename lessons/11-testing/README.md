# Lesson 11: Testing in Haskell

## Introduction

Haskell has a reputation for "if it compiles, it works." There is some
truth to that -- the type system catches many bugs at compile time. But
types alone cannot verify that your search function returns the right
results or that your JSON serialization round-trips correctly.

Testing fills that gap. And here is the good news: **pure functions are
spectacularly easy to test.** No mocks, no setup, no teardown. Call the
function, check the result.

In this lesson we cover two complementary testing approaches:

* **HUnit** -- traditional unit tests (like JUnit, pytest, etc.)
* **QuickCheck** -- property-based testing, a technique Haskell pioneered

We then use **tasty** as a test framework to combine both in a single
test suite.

---

## 1  Unit Testing with HUnit

### 1.1  The Idea

A unit test calls a function with known inputs and asserts that the
output matches an expected value:

```haskell
import Test.HUnit

testAddition :: Test
testAddition = TestCase (assertEqual "1 + 1 should be 2" 2 (1 + 1))
```

### 1.2  Assertion Functions

HUnit provides several assertion helpers:

```haskell
-- Check that two values are equal (expected, actual)
assertEqual :: (Eq a, Show a) => String -> a -> a -> Assertion

-- Check that a boolean condition holds
assertBool :: String -> Bool -> Assertion

-- Check that a value is True
assertFailure :: String -> Assertion  -- always fails with message
```

### 1.3  Operators for Concise Tests

HUnit also provides infix operators:

```haskell
-- expected @=? actual  (note: expected on the LEFT)
(@=?) :: (Eq a, Show a) => a -> a -> Assertion

-- actual @?= expected  (note: actual on the LEFT)
(@?=) :: (Eq a, Show a) => a -> a -> Assertion

-- "message" @? boolExpr
(@?) :: AssertionPredicable t => t -> String -> Assertion
```

Example:

```haskell
test1 = TestCase (2 @=? (1 + 1))
test2 = TestCase ((1 + 1) @?= 2)
test3 = TestCase (True @? "should be true")
```

### 1.4  Organizing Tests

HUnit provides constructors to group tests:

```haskell
-- A single test
TestCase :: Assertion -> Test

-- A labeled test (gives it a name)
TestLabel :: String -> Test -> Test

-- A list of tests
TestList :: [Test] -> Test
```

You can nest them:

```haskell
allTests :: Test
allTests = TestList
  [ TestLabel "addition" (TestCase (assertEqual "" 2 (1 + 1)))
  , TestLabel "reverse"  (TestCase (assertEqual "" [3,2,1] (reverse [1,2,3])))
  ]
```

---

## 2  Property-Based Testing with QuickCheck

### 2.1  The Idea

Instead of writing individual test cases, you describe **properties**
that should hold for *all* inputs, and QuickCheck generates random
inputs to try to falsify them.

```haskell
import Test.QuickCheck

-- For any list of integers, reversing twice gives back the original
prop_reverseReverse :: [Int] -> Bool
prop_reverseReverse xs = reverse (reverse xs) == xs
```

QuickCheck will test this with 100 random lists (by default). If it
finds a counterexample, it reports the failing input.

### 2.2  Running Properties

```haskell
-- In GHCi:
> quickCheck prop_reverseReverse
+++ OK, passed 100 tests.

-- With a specific number of tests:
> quickCheckWith stdArgs { maxSuccess = 1000 } prop_reverseReverse
```

### 2.3  The Property Type

QuickCheck works with anything that is `Testable`:

```haskell
property :: Testable prop => prop -> Property
```

The simplest testable things are:

* `Bool` -- pass if True, fail if False
* `a -> Bool` where `a` has an `Arbitrary` instance
* `a -> b -> Bool` for multiple arguments
* `a -> Property` for more control

### 2.4  The Arbitrary Typeclass

QuickCheck generates random values through `Arbitrary`:

```haskell
class Arbitrary a where
  arbitrary :: Gen a
  shrink    :: a -> [a]  -- optional, used to minimize failing cases
```

Instances exist for all common types: `Int`, `Bool`, `String`,
`[a]`, `Maybe a`, tuples, etc.

### 2.5  Writing Custom Arbitrary Instances

For your own types, you need to tell QuickCheck how to generate them:

```haskell
data Priority = Low | Medium | High
  deriving (Show, Eq, Ord)

instance Arbitrary Priority where
  arbitrary = elements [Low, Medium, High]
```

For record types, combine generators:

```haskell
instance Arbitrary Note where
  arbitrary = do
    nid  <- arbitrary             -- random Int
    t    <- arbitrary             -- random String
    b    <- arbitrary             -- random String
    tgs  <- listOf arbitrary      -- random list of Strings
    p    <- arbitrary             -- random Priority
    return (Note nid t b tgs p)
```

Useful generator combinators:

```haskell
elements  :: [a] -> Gen a            -- pick one from a list
oneof     :: [Gen a] -> Gen a        -- pick one generator
frequency :: [(Int, Gen a)] -> Gen a -- weighted choice
listOf    :: Gen a -> Gen [a]        -- random-length list
vectorOf  :: Int -> Gen a -> Gen [a] -- fixed-length list
choose    :: Random a => (a, a) -> Gen a  -- range
```

### 2.6  forAll: Custom Generators Without Instances

Sometimes you want a custom generator for a specific test without
writing a full `Arbitrary` instance:

```haskell
prop_positiveSquare :: Property
prop_positiveSquare =
  forAll (choose (1, 1000)) $ \n ->
    n * n > 0
```

### 2.7  Shrinking

When QuickCheck finds a failing input, it tries to **shrink** it to the
smallest input that still fails. This is incredibly useful for debugging.

For example, if a property fails for the list `[42, -7, 100, 3]`,
QuickCheck might shrink it down to `[-1]` -- a much more informative
counterexample.

Define `shrink` in your `Arbitrary` instance:

```haskell
instance Arbitrary Priority where
  arbitrary = elements [Low, Medium, High]
  shrink High   = [Medium, Low]
  shrink Medium = [Low]
  shrink Low    = []
```

For types that derive `Generic`, you can use `genericShrink`:

```haskell
{-# LANGUAGE DeriveGeneric #-}
import GHC.Generics (Generic)
import Test.QuickCheck.Arbitrary.Generic (genericArbitrary, genericShrink)

data Priority = Low | Medium | High
  deriving (Show, Eq, Ord, Generic)

instance Arbitrary Priority where
  arbitrary = genericArbitrary
  shrink    = genericShrink
```

---

## 3  Tasty: A Test Framework

### 3.1  Why Tasty?

HUnit and QuickCheck work on their own, but **tasty** gives you a
unified framework that:

* Combines HUnit tests and QuickCheck properties in one tree
* Provides structured, colored output
* Supports filtering tests by name
* Has a clean, composable API

### 3.2  Core API

```haskell
import Test.Tasty
import Test.Tasty.HUnit       -- for testCase
import Test.Tasty.QuickCheck  -- for testProperty

-- Build a test tree
defaultMain :: TestTree -> IO ()

-- Group tests
testGroup :: TestName -> [TestTree] -> TestTree

-- HUnit test
testCase :: TestName -> Assertion -> TestTree

-- QuickCheck property
testProperty :: Testable a => TestName -> a -> TestTree
```

### 3.3  Example

```haskell
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "All Tests"
  [ testGroup "Unit Tests"
      [ testCase "1 + 1 = 2" $
          (1 + 1) @?= (2 :: Int)
      , testCase "reverse preserves length" $
          length (reverse [1,2,3]) @?= 3
      ]
  , testGroup "Properties"
      [ testProperty "reverse . reverse = id" $
          \xs -> reverse (reverse xs) == (xs :: [Int])
      , testProperty "length is non-negative" $
          \xs -> length (xs :: [Int]) >= 0
      ]
  ]
```

---

## 4  Setting Up Tests in a Cabal Project

### 4.1  The Library Approach

To let both your executable and your tests import the same modules, the
cleanest approach is to split your `.cabal` file into three sections:

1. **library** -- exposes all your `Hask.*` modules
2. **executable** -- depends on the library
3. **test-suite** -- depends on the library plus testing packages

```cabal
cabal-version: 2.4
name:          hask
version:       0.1.0.0

library
  hs-source-dirs:   src
  exposed-modules:
    Hask.Types
    Hask.Search
  build-depends:
    base >= 4.14 && < 5
  default-language: Haskell2010

executable hask
  main-is:          Main.hs
  hs-source-dirs:   src
  build-depends:
    base >= 4.14 && < 5,
    hask
  default-language: Haskell2010

test-suite hask-tests
  type:             exitcode-stdio-1.0
  main-is:          Test.hs
  hs-source-dirs:   test
  build-depends:
    base >= 4.14 && < 5,
    hask,
    tasty,
    tasty-hunit,
    tasty-quickcheck,
    QuickCheck
  default-language: Haskell2010
```

### 4.2  exitcode-stdio-1.0

This test type means: the test program exits with code 0 if all tests
pass, and non-zero otherwise. Cabal interprets the exit code to
report success or failure. Both tasty and HUnit support this out of
the box.

### 4.3  Running Tests

```bash
cd app
cabal test            # build and run all test suites
cabal test --test-show-details=direct  # show output in real time
```

---

## 5  What to Test

### 5.1  Pure Functions First

Pure functions are the easiest and most valuable things to test:

* **Search logic**: does `searchNotes "haskell" notes` return the right
  notes? Does it handle empty queries? Is it case-insensitive?
* **Filtering**: does `filterByTag "shopping" notes` work?
* **Data transformations**: does serialization round-trip correctly?

### 5.2  Properties of Your Data

Think about invariants:

* Searching for `""` (empty string) should return all notes.
* Search should be case-insensitive: searching for `"ABC"` and `"abc"`
  should return the same results.
* Adding a note and then listing should include that note.
* The number of search results should never exceed the number of notes.

### 5.3  Unit Tests for Edge Cases

* Empty list of notes.
* Query that matches nothing.
* Query that matches everything.
* Notes with empty titles, empty tags, etc.

---

## 6  Test-Driven Development (TDD) in Haskell

Because Haskell separates pure and impure code, TDD works beautifully:

1. Write a type signature for your function.
2. Write tests for that function.
3. Implement the function until all tests pass.
4. Refactor with confidence (tests catch regressions).

The strong type system and QuickCheck together give you very high
confidence in your code.

---

## Summary

| Concept                | Key Takeaway                                      |
|------------------------|---------------------------------------------------|
| HUnit                  | Traditional assertions: assertEqual, @?=          |
| QuickCheck             | Property-based testing with random inputs         |
| Arbitrary              | Typeclass for generating random test values        |
| Shrinking              | QuickCheck minimizes failing inputs automatically |
| forAll                 | Custom generators for specific tests              |
| tasty                  | Unified framework combining HUnit + QuickCheck    |
| testGroup              | Organize tests into a tree                        |
| testCase               | Wrap a HUnit assertion as a test tree node        |
| testProperty           | Wrap a QuickCheck property as a test tree node    |
| library in .cabal      | Share modules between executable and test suite   |
| cabal test             | Build and run the test suite                      |

---

Next lesson: Final polish and review.
