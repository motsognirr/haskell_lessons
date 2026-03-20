# Lesson 07: IO & File Operations

## Introduction

So far, every Haskell function we have written has been **pure** -- given the same
inputs, it always returns the same output, and it never changes anything in the
outside world. But real programs need to talk to the outside world: read files,
print to the terminal, accept user input, and save data.

That is where **IO** comes in.

---

## The IO Type: Recipes for Side Effects

In Haskell, a value of type `IO a` is not a result -- it is a **recipe** (or
**description**) of an action that, when executed, may perform side effects and
eventually produce a value of type `a`.

```haskell
putStrLn "hello" :: IO ()     -- a recipe that prints "hello" and produces ()
getLine          :: IO String  -- a recipe that reads a line and produces a String
readFile "x.txt" :: IO String  -- a recipe that reads a file and produces its contents
```

Think of `IO String` the way you think of a sealed envelope with instructions
inside. The envelope itself is a pure Haskell value. Only when the Haskell
runtime **executes** the instructions does anything happen in the real world.

Your `main` function has type `IO ()`. The runtime executes whatever recipe
`main` describes.

---

## `do` Notation: Sequencing IO Actions

When you need to run several IO actions one after another, use `do` notation:

```haskell
main :: IO ()
main = do
    putStrLn "What is your name?"
    name <- getLine
    putStrLn ("Hello, " ++ name ++ "!")
```

### `<-` vs `let` in `do` Blocks

These two look similar but mean very different things:

```haskell
do
    line <- getLine          -- run an IO action, bind the result to `line`
    let upper = map toUpper line  -- pure computation, no IO involved
    putStrLn upper
```

- **`x <- action`** -- "Execute this IO action and call the result `x`."
- **`let x = expr`** -- "Compute this pure expression and call the result `x`."
  (No `in` keyword needed inside `do` blocks.)

---

## Common IO Functions

### Console

```haskell
putStrLn :: String -> IO ()       -- print a string with a newline
putStr   :: String -> IO ()       -- print without a newline
print    :: Show a => a -> IO ()  -- print any showable value (calls show first)
getLine  :: IO String             -- read one line of input
```

### File I/O

```haskell
readFile   :: FilePath -> IO String            -- read entire file as a String
writeFile  :: FilePath -> String -> IO ()       -- overwrite file with content
appendFile :: FilePath -> String -> IO ()       -- append to a file
```

`FilePath` is just a type alias for `String`.

### Directory Operations (System.Directory)

```haskell
import System.Directory

doesFileExist          :: FilePath -> IO Bool
doesDirectoryExist     :: FilePath -> IO Bool
createDirectoryIfMissing :: Bool -> FilePath -> IO ()
                          -- True = create parent dirs too
getCurrentDirectory    :: IO FilePath
```

---

## `return` Does Not Exit!

In most languages, `return` exits a function. In Haskell, `return` wraps a pure
value into IO:

```haskell
return :: a -> IO a
```

It does **not** stop execution. This is a common mistake:

```haskell
-- WRONG thinking: "return exits early"
checkAge :: Int -> IO ()
checkAge age = do
    if age < 18
      then return ()   -- does NOT exit the function!
      else putStrLn "Welcome"
    putStrLn "This always runs"

-- CORRECT approach
checkAge :: Int -> IO ()
checkAge age = do
    if age < 18
      then putStrLn "Too young"
      else putStrLn "Welcome"
```

---

## Pure vs Impure: Why Haskell Separates Them

The type system enforces the separation. A function with type
`String -> String` **cannot** read a file or print to the screen.
Only functions that return `IO something` can perform side effects.

This gives you strong guarantees:

- If you see `foo :: [Int] -> Int`, you know it cannot delete your files.
- All side effects are visible in the type signature.
- Pure functions are easy to test -- no mocking needed.

---

## Traversing with `mapM`, `mapM_`, `forM`, `forM_`

When you have a list and want to perform an IO action for each element:

```haskell
mapM_ :: (a -> IO b) -> [a] -> IO ()    -- like map, but for IO; discard results
mapM  :: (a -> IO b) -> [a] -> IO [b]   -- like map, but for IO; collect results

forM_ :: [a] -> (a -> IO b) -> IO ()    -- same as mapM_ with args flipped
forM  :: [a] -> (a -> IO b) -> IO [b]   -- same as mapM  with args flipped
```

```haskell
import Control.Monad (forM_)

printNumbered :: [String] -> IO ()
printNumbered items =
    forM_ (zip [1..] items) $ \(i, item) ->
        putStrLn (show i ++ ". " ++ item)
```

Use `mapM_` / `forM_` (with underscore) when you do not need the results --
this is the common case for printing.

---

## Using `show` and `read` for Simple Serialization

Haskell's `Show` and `Read` type classes give you a quick way to save and
load data:

```haskell
data Color = Red | Green | Blue
  deriving (Show, Read)

-- Save
writeFile "color.dat" (show Red)

-- Load
contents <- readFile "color.dat"
let color = read contents :: Color
```

For lists and records it works the same way:

```haskell
data Item = Item { name :: String, count :: Int }
  deriving (Show, Read)

items :: [Item]
items = [Item "apples" 3, Item "bread" 1]

-- Save a list
writeFile "items.dat" (show items)

-- Load a list
contents <- readFile "items.dat"
let loaded = read contents :: [Item]
```

**Important**: `deriving Read` must be added to your data types. Both the type
and all types it contains must have `Read` instances.

---

## Practical Pattern: Load -> Process -> Save

A very common pattern in file-based programs:

```haskell
import System.Directory (doesFileExist)

loadItems :: FilePath -> IO [Item]
loadItems path = do
    exists <- doesFileExist path
    if exists
      then do
        contents <- readFile path
        return (read contents)
      else return []

saveItems :: FilePath -> [Item] -> IO ()
saveItems path items = writeFile path (show items)

addItem :: FilePath -> Item -> IO ()
addItem path item = do
    items <- loadItems path
    saveItems path (items ++ [item])
```

This is the pattern you will use in this lesson's exercise to add persistence
to the `hask` note manager.

---

## Working with File Paths

`FilePath` is just `String`, so you can build paths with `++` or use
`System.FilePath` for portable path manipulation:

```haskell
import System.FilePath ((</>))

dataDir :: FilePath
dataDir = "data"

notesFile :: FilePath
notesFile = dataDir </> "notes.dat"
-- On Linux/Mac: "data/notes.dat"
-- On Windows:   "data\\notes.dat"
```

For this lesson we keep it simple and use a single file in the current directory.

---

## Handling Read Failures

`read` will crash if the file content is malformed. For production code you would
use `readMaybe` from `Text.Read`:

```haskell
import Text.Read (readMaybe)

loadItemsSafe :: FilePath -> IO [Item]
loadItemsSafe path = do
    exists <- doesFileExist path
    if exists
      then do
        contents <- readFile path
        case readMaybe contents of
          Just items -> return items
          Nothing    -> do
            putStrLn "Warning: could not parse file, starting fresh."
            return []
      else return []
```

For the exercise, plain `read` is fine since we control the file format.

---

## Strict vs Lazy File Reading

`readFile` is **lazy** -- it does not read the whole file into memory at once.
This is usually fine, but it can cause problems if you try to read and then
immediately write to the same file (the file handle may still be open).

A safe pattern when you need to read-then-write the same file:

```haskell
import Control.DeepSeq (force)
import Control.Exception (evaluate)

loadStrict :: FilePath -> IO String
loadStrict path = do
    contents <- readFile path
    evaluate (force contents)
```

For our exercise, we read from one logical operation and write in another,
so lazy `readFile` works fine.

---

## Summary

| Concept | Key Point |
|---------|-----------|
| `IO a` | A description of an action that produces an `a` |
| `do` notation | Sequences IO actions |
| `<-` | Binds the result of an IO action |
| `let` | Pure computation inside `do` |
| `return` | Wraps a pure value in IO (does **not** exit) |
| `readFile` / `writeFile` | Basic file I/O |
| `doesFileExist` | Check before reading |
| `show` / `read` | Simple serialization |
| `mapM_` / `forM_` | Apply IO action to each list element |

Next lesson, we will look at error handling with `Maybe` and `Either` to make
our IO code more robust.
