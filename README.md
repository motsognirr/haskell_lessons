# Learn Haskell with Claude Code

An interactive Haskell course for experienced programmers, run entirely through Claude Code.

## What You'll Build

Over 13 lessons (00-12), you'll learn Haskell from scratch and build **`hask`** -- a CLI note/knowledge-base manager. The final tool supports:

- `hask add "title" --tags "a,b"` -- Add notes with tags
- `hask search "query"` -- Full-text search
- `hask list --tag x` -- Filter by tag
- `hask delete ID` -- Remove notes
- `hask export --format md` -- Export in multiple formats

## Prerequisites

- A working terminal (macOS, Linux, or WSL)
- Claude Code installed and configured
- Some programming experience (any language)

## Getting Started

1. Open this directory in Claude Code
2. Run `/start-lesson` to begin Lesson 00
3. Read the lesson material Claude presents
4. Complete the exercise
5. Run `/end-lesson` when you think you're done
6. If stuck, run `/hint` for a nudge in the right direction

## Course Structure

| # | Lesson | Focus |
|---|--------|-------|
| 00 | Setup & Hello World | Install GHCup, first program |
| 01 | Types & Functions | Basic types, signatures, where/let |
| 02 | Lists & Pattern Matching | Lists, Maybe, guards, case |
| 03 | Recursion & Higher-Order Functions | map/filter/fold, lambdas |
| 04 | Algebraic Data Types | data, records, sum/product types |
| 05 | Typeclasses | class/instance, Eq/Ord/Show |
| 06 | Modules & Project Setup | Cabal, modules, imports |
| 07 | IO & File Operations | File read/write, do notation |
| 08 | Error Handling | Maybe/Either, custom errors |
| 09 | Libraries (Aeson + Optparse) | JSON, CLI parsing |
| 10 | Monads & Transformers | ExceptT, ReaderT, App monad |
| 11 | Testing | HUnit, QuickCheck, property tests |
| 12 | Polish & Ship | Data.Text, colors, export, install |

## Commands

- `/start-lesson [N]` -- Begin a lesson (next lesson by default, or specify N)
- `/end-lesson` -- Submit your work for grading
- `/hint` -- Get a conceptual hint for the current exercise
