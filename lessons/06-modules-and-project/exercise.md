# Exercise 06: Create the hask Project

Set up the `hask` Cabal project with proper module structure.

## What to Build

Create the `app/` directory with a proper Cabal project containing:

### 1. `app/hask.cabal`

A Cabal file for an executable called `hask` with:
- `hs-source-dirs: src`
- `main-is: Main.hs`
- `build-depends: base >= 4.14 && < 5`
- `default-language: Haskell2010`
- `other-modules` listing Hask.Types and Hask.Search

### 2. `app/src/Main.hs`

The entry point. For now it should:
- Import Hask.Types and Hask.Search
- Import System.Environment (getArgs)
- Read command-line args
- Support two commands:
  - `hask search <query>` -- search sample notes and print matches
  - Anything else -- print usage: "Usage: hask search <query>"
- Create a sample list of at least 3 notes with varied tags and priorities
- When searching, print each matching note's title

### 3. `app/src/Hask/Types.hs`

Module `Hask.Types` exporting:
- `data Priority = Low | Medium | High` (deriving Show, Eq, Ord)
- `data Note = Note { noteId :: Int, title :: String, body :: String, tags :: [String], priority :: Priority }` (deriving Show, Eq)

### 4. `app/src/Hask/Search.hs`

Module `Hask.Search` exporting:
- `searchNotes :: String -> [Note] -> [Note]` -- case-insensitive search across title, body, and tags
- Implement the case-insensitive search without external libraries (use Data.Char.toLower and write your own isInfixOf or import Data.List)

## Requirements

- The project must compile with `cabal build` (run from the `app/` directory)
- `cabal run hask` should print usage info
- `cabal run hask -- search "haskell"` should find and print matching notes from the sample data
- Search must be case-insensitive

## Hints

- Remember: module name must match file path (`Hask.Types` -> `src/Hask/Types.hs`)
- Use `Data.Char (toLower)` for case-insensitive comparison
- You can use `Data.List (isInfixOf)` or write your own
- Test with `cabal run hask -- search "some term"` (the `--` separates cabal args from program args)
