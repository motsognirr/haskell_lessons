# Exercise 11: Add a Test Suite to hask

Add automated tests to the `hask` note-taking app using HUnit (unit
tests) and QuickCheck (property-based tests), unified under the tasty
framework.

## What to Build

### 1. Update `app/hask.cabal`

Restructure the cabal file to use a **library** section so that both the
executable and the test suite can import the same `Hask.*` modules.

Add a `test-suite` section:

```cabal
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

The library section should expose at least `Hask.Types` and
`Hask.Search`. The executable should depend on the library (`hask`).

### 2. Create `app/test/Test.hs`

Write a test file using tasty that includes **at least 5 tests** -- a mix
of unit tests and property-based tests.

#### Required Unit Tests

1. **Search finds matching notes**: Create a known list of notes,
   search for a term that appears in one of them, and assert the result
   contains exactly the expected notes.

2. **Search does not find non-matching notes**: Search for a term that
   does not appear in any note, and assert the result is empty.

3. **filterByTag works** (if you have this function) or another unit test
   of your choice on a pure function from the project.

#### Required Property Tests

4. **Empty query returns all notes**: For any list of notes, searching
   for `""` should return the entire list.

   ```haskell
   \notes -> searchNotes "" notes == notes
   ```

5. **Search is case-insensitive**: For any list of notes and any query
   string, searching with the query uppercased and lowercased should give
   the same results.

   ```haskell
   \notes query -> searchNotes (map toUpper query) notes
                == searchNotes (map toLower query) notes
   ```

#### Structure

Use `testGroup` to organize the tests:

```haskell
main :: IO ()
main = defaultMain $ testGroup "Hask Tests"
  [ testGroup "Unit Tests" [ ... ]
  , testGroup "Property Tests" [ ... ]
  ]
```

### 3. Write Arbitrary Instances

To use QuickCheck with your `Note` and `Priority` types, write
`Arbitrary` instances for them:

```haskell
instance Arbitrary Priority where
  arbitrary = elements [Low, Medium, High]

instance Arbitrary Note where
  arbitrary = Note
    <$> arbitrary
    <*> arbitrary
    <*> arbitrary
    <*> listOf arbitrary
    <*> arbitrary
```

## Requirements

- `cabal build all` must succeed (both the executable and test suite compile)
- `cabal test` must pass with all tests succeeding
- The test file must include at least 2 unit tests (`testCase`)
- The test file must include at least 2 property tests (`testProperty`)
- Tests must import and exercise functions from the `hask` library
  (not just test standalone arithmetic)

## Hints

- Remember to add a `library` section to the `.cabal` file so the test
  suite can import `Hask.Types` and `Hask.Search`.
- The executable's `Main.hs` should NOT be in the library's
  `exposed-modules` -- only the `Hask.*` modules belong there.
- Keep the executable's `hs-source-dirs` separate from the library's
  if `Main.hs` lives alongside the `Hask/` directory. A common pattern
  is to put library code in `src/` and the executable `Main.hs` also
  in `src/` but only list `Hask.*` modules in the library.
- For the `Arbitrary Note` instance, `listOf arbitrary` generates a
  random list of random strings for the tags field.
- Run tests with `cabal test --test-show-details=direct` to see
  individual test results.
