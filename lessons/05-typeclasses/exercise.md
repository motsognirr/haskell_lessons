# Exercise 05: Typeclasses

## Goal

Create a file called `Main.hs` in this directory
(`lessons/05-typeclasses/Main.hs`) and implement the types, typeclasses, and
instances described below. The file should compile with `ghc` and produce the
expected output when run.

---

## Setup

Your file should start with:

```haskell
{-# LANGUAGE FlexibleInstances #-}
module Main where

import Data.List (isInfixOf, intercalate)
```

The `FlexibleInstances` pragma is needed for the `Displayable [Note]` instance.
The `Data.List` import gives you `isInfixOf` (for substring search) and
`intercalate` (for joining strings with a separator).

---

## Types to Define

Re-define the `Priority` and `Note` types from Lesson 04:

```haskell
data Priority = Low | Medium | High
  deriving (Eq, Ord)

data Note = Note
  { noteTitle :: String
  , noteBody  :: String
  , noteTags  :: [String]
  , priority  :: Priority
  }
```

Notice that `Priority` derives `Eq` and `Ord` but **not** `Show`. You will write
a custom `Show` instance instead.

---

## Instances and Typeclasses to Implement

### 1. Custom `Show` Instance for `Priority`

Write a `Show` instance for `Priority` that displays each constructor as a
bracketed label:

| Constructor | `show` result |
|-------------|---------------|
| `Low`       | `"[LOW]"`     |
| `Medium`    | `"[MED]"`     |
| `High`      | `"[!!!]"`     |

**Example:**
```
ghci> show High
"[!!!]"
ghci> show Low
"[LOW]"
```

### 2. Define the `Displayable` Typeclass

Define a typeclass called `Displayable` with a single method:

```haskell
class Displayable a where
  display :: a -> String
```

### 3. `Displayable` Instance for `Note`

Implement `Displayable` for `Note`. The `display` function should produce a
string in this format:

```
[priority] title (tags: tag1, tag2)
```

Where:
- `[priority]` is the `show` output of the note's priority (e.g., `[!!!]`)
- `title` is the note's title
- Tags are joined with `", "`

**Example:**
```
ghci> display sampleNote
"[!!!] My Note (tags: haskell, fp)"
```

**Hint:** You can use `intercalate ", "` to join a list of strings with `", "` as
separator. Or you can write a recursive helper function.

### 4. `Displayable` Instance for `[Note]`

Implement `Displayable` for `[Note]` (a list of notes). This should display each
note on its own line, using the `display` function for each individual note.

**Hint:** Use `unlines` and `map`.

This is where the `FlexibleInstances` pragma is needed, because `[Note]` is a
specific type rather than a type variable.

### 5. Define the `Searchable` Typeclass

Define a typeclass called `Searchable` with a single method:

```haskell
class Searchable a where
  search :: String -> a -> Bool
```

The idea: `search term x` returns `True` if `term` can be found in `x`.

### 6. `Searchable` Instance for `Note`

Implement `Searchable` for `Note`. A search should return `True` if the search
term appears in any of:

- The note's title (as a substring)
- The note's body (as a substring)
- Any of the note's tags (exact match)

Use `isInfixOf` for substring matching and `any` for checking the tag list.

**Example:**
```
ghci> search "haskell" sampleNote
True
ghci> search "python" sampleNote
False
```

---

## The `main` Function

Your `main` function should demonstrate all the instances:

```haskell
main :: IO ()
main = do
  let note1 = Note
        { noteTitle = "My Note"
        , noteBody  = "Learn about typeclasses"
        , noteTags  = ["haskell", "fp"]
        , priority  = High
        }

  putStrLn (show High)
  putStrLn (display note1)
  print (search "haskell" note1)
  print (search "python" note1)
```

---

## Expected Output

When you compile and run your program, the output should be exactly:

```
[!!!]
[!!!] My Note (tags: haskell, fp)
True
False
```

---

## How to Compile and Run

```bash
cd lessons/05-typeclasses
ghc -o typeclasses Main.hs
./typeclasses
```

---

## Hints

- Do **not** derive `Show` for `Priority` -- write it manually.
- `isInfixOf` from `Data.List` checks if one string is a substring of another:
  `isInfixOf "ask" "haskell"` is `True`.
- `intercalate ", " ["a", "b", "c"]` gives `"a, b, c"`.
- `any (== "haskell") ["haskell", "fp"]` gives `True`.
- For the `[Note]` instance, `unlines (map display notes)` will add a newline
  after each note.
- Remember to use `putStrLn` for strings and `print` for other types. `print x`
  is equivalent to `putStrLn (show x)`.

---

## Checking Your Work

Your solution passes when:

1. The file exists at `lessons/05-typeclasses/Main.hs`
2. It defines the `Searchable` typeclass
3. It has a custom `Show` instance for `Priority`
4. It compiles without errors: `ghc -o typeclasses Main.hs`
5. Running `./typeclasses` produces the exact output shown above
