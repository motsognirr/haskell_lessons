# Lesson 06: Modules & Project Setup

Time to graduate from single-file programs to a real Haskell project! In this lesson, you'll set up the `hask` CLI application using Cabal -- Haskell's build system.

## Modules

Every Haskell file is a module. Until now, all your code lived in `Main`. Real projects split code across multiple modules.

### Declaring a Module

```haskell
module Hask.Types where

data Priority = Low | Medium | High
  deriving (Show, Eq, Ord)
```

The module name must match the file path: `Hask.Types` lives in `Hask/Types.hs` (or `src/Hask/Types.hs` if using a `src` directory).

### Exporting

By default, everything in a module is exported. You can restrict exports:

```haskell
module Hask.Types
  ( Priority(..)    -- Export type and ALL constructors
  , Note(..)        -- Export type and all record fields
  , NoteId          -- Export type but NOT constructors (opaque)
  ) where
```

The `(..)` exports all constructors/fields. Without it, you export only the type name.

### Importing

```haskell
-- Import everything from a module
import Hask.Types

-- Import specific items
import Hask.Types (Note(..), Priority(..))

-- Qualified import (must use prefix)
import qualified Data.Map as Map

-- Import everything except specific items
import Hask.Types hiding (NoteId)
```

### Import Best Practices

- Use qualified imports for modules with common names (Map, Set, Text)
- Import specific items when you only need a few things
- Put standard library imports first, then third-party, then your own

## Cabal: Haskell's Build System

Cabal is Haskell's package manager and build tool (like cargo for Rust, npm for Node).

### The .cabal File

Every Cabal project has a `.cabal` file describing the project:

```cabal
cabal-version: 2.4
name:          hask
version:       0.1.0.0
synopsis:      A CLI note manager
license:       MIT

executable hask
  main-is:          Main.hs
  hs-source-dirs:   src
  build-depends:
    base >= 4.14 && < 5
  default-language: Haskell2010
  other-modules:
    Hask.Types
    Hask.Search
```

Key sections:
- **executable**: Defines a program to build
- **main-is**: The entry point file
- **hs-source-dirs**: Where to find source files
- **build-depends**: Library dependencies
- **other-modules**: Non-Main modules that are part of this executable

### cabal.project (optional)

For simple projects, you don't need this. But it's common to have one:

```
packages: .
```

### Essential Cabal Commands

```bash
cabal build        # Compile the project
cabal run          # Build and run the executable
cabal run hask     # Run specific executable (if multiple)
cabal run hask -- add "My Note"  # Pass args after --
cabal clean        # Remove build artifacts
cabal init         # Create a new project interactively
```

### Adding Dependencies

To use a library, add it to `build-depends`:

```cabal
build-depends:
  base >= 4.14 && < 5,
  containers >= 0.6
```

Then import it in your Haskell code:

```haskell
import qualified Data.Map.Strict as Map
```

Cabal will automatically download and build the dependency.

## Project Structure

A typical Haskell project:

```
my-project/
  my-project.cabal   -- Project metadata and build config
  src/
    Main.hs           -- Entry point
    MyProject/
      Types.hs        -- Data types
      Logic.hs        -- Business logic
  test/
    Test.hs           -- Tests (we'll add these in lesson 11)
```

### The src/ Directory Convention

Putting source files under `src/` keeps things organized and prevents Cabal from accidentally including non-source files. Set `hs-source-dirs: src` in your .cabal file.

## Working with Multiple Modules

Here's how modules reference each other:

```haskell
-- src/Hask/Types.hs
module Hask.Types where

data Priority = Low | Medium | High deriving (Show, Eq, Ord)

data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Eq)
```

```haskell
-- src/Hask/Search.hs
module Hask.Search where

import Data.Char (toLower)
import Hask.Types

searchNotes :: String -> [Note] -> [Note]
searchNotes query = filter (matchesQuery query)

matchesQuery :: String -> Note -> Bool
matchesQuery query note =
  let q = map toLower query
  in q `isInfixOf'` map toLower (title note)
     || q `isInfixOf'` map toLower (body note)
     || any (\t -> q `isInfixOf'` map toLower t) (tags note)

isInfixOf' :: String -> String -> Bool
isInfixOf' needle haystack = any (isPrefixOf needle) (tails haystack)

isPrefixOf :: String -> String -> Bool
isPrefixOf [] _          = True
isPrefixOf _ []          = False
isPrefixOf (x:xs) (y:ys) = x == y && isPrefixOf xs ys

tails :: [a] -> [[a]]
tails [] = [[]]
tails xs@(_:xs') = xs : tails xs'
```

```haskell
-- src/Main.hs
module Main where

import Hask.Types
import Hask.Search
import System.Environment (getArgs)

main :: IO ()
main = do
    args <- getArgs
    -- We'll build this out over the next lessons
    putStrLn "hask - Note Manager"
    putStrLn "Usage: hask <command>"
```

## Key Takeaways

- Modules organize code into namespaces matching the file path
- Export lists control what's visible outside a module
- Cabal manages building, dependencies, and project structure
- `cabal build` compiles, `cabal run` compiles and runs
- Use `hs-source-dirs: src` and put your code under `src/`
- List all non-Main modules in `other-modules`
