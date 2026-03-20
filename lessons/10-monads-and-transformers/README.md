# Lesson 10: Monads & Transformers

## What Monads Actually Are

You have been using monads since lesson 07, maybe without knowing it. Every time
you wrote a `do` block with `IO`, you were working inside a monad. A monad is not
a burrito, a box, or a spaceship -- it is a **pattern for sequencing computations
that carry some context**.

The "context" depends on the monad:

| Monad     | Context                              |
|-----------|--------------------------------------|
| `IO`      | Side effects (files, console, etc.)  |
| `Maybe`   | Computation that might fail silently |
| `Either e`| Computation that might fail with an error |
| `[]`      | Computation with multiple results    |

The key idea: each step in the sequence can use the result of the previous step,
and the monad handles the "plumbing" (propagating failures, threading state,
collecting effects) behind the scenes.

---

## The Monad Typeclass

```haskell
class Applicative m => Monad m where
    return :: a -> m a
    (>>=)  :: m a -> (a -> m b) -> m b
```

Two operations:

- **`return`** (also called `pure`): Wrap a plain value in the monad.
- **`>>=`** ("bind"): Take a monadic value, extract the result, feed it to a
  function that produces a new monadic value.

That is it. Everything else is built on top of these two.

### Maybe Example

```haskell
safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing
safeDivide x y = Just (x `div` y)

-- Using >>= explicitly
compute :: Int -> Int -> Int -> Maybe Int
compute a b c =
    safeDivide a b >>= \ab ->
    safeDivide ab c
```

If any step returns `Nothing`, the whole chain short-circuits to `Nothing`.
You do not write a single `if` or `case` -- the `Maybe` monad handles it.

---

## do Notation Is Syntax Sugar for >>=

Every `do` block is mechanically translated into calls to `>>=` and `>>`.
You can always desugar by hand:

```haskell
-- do notation
doVersion :: IO ()
doVersion = do
    name <- getLine
    let greeting = "Hello, " ++ name
    putStrLn greeting

-- desugared
bindVersion :: IO ()
bindVersion =
    getLine >>= \name ->
    let greeting = "Hello, " ++ name
    in putStrLn greeting
```

The rules:

| do notation               | Desugared form                        |
|---------------------------|---------------------------------------|
| `do { x <- action; rest }`| `action >>= \x -> do { rest }`      |
| `do { action; rest }`     | `action >> do { rest }`              |
| `do { let x = e; rest }`  | `let x = e in do { rest }`           |
| `do { action }`           | `action`                              |

Another example with `Maybe`:

```haskell
lookupAge :: String -> [(String, Int)] -> Maybe Int
lookupAge name db = do
    entry <- lookup name db        -- Maybe Int
    if entry >= 0
      then Just entry
      else Nothing

-- desugared:
lookupAge' :: String -> [(String, Int)] -> Maybe Int
lookupAge' name db =
    lookup name db >>= \entry ->
    if entry >= 0
      then Just entry
      else Nothing
```

Understanding desugaring is not just academic -- it helps you debug type errors
in `do` blocks and understand what the compiler actually sees.

---

## Common Monads You Already Know

### IO

```haskell
main :: IO ()
main = do
    line <- getLine       -- IO String, extract the String
    putStrLn line         -- use it
```

Context: side effects.

### Maybe

```haskell
safeHead :: [a] -> Maybe a
safeHead []    = Nothing
safeHead (x:_) = Just x

firstTwo :: [a] -> Maybe (a, a)
firstTwo xs = do
    a <- safeHead xs
    b <- safeHead (drop 1 xs)
    return (a, b)
```

Context: might not have a value.

### Either e

```haskell
parseAge :: String -> Either String Int
parseAge s = case readMaybe s of
    Nothing -> Left "Not a number"
    Just n  -> if n < 0 then Left "Negative age" else Right n

validatePerson :: String -> String -> Either String (String, Int)
validatePerson name ageStr = do
    age <- parseAge ageStr
    if null name
      then Left "Empty name"
      else Right (name, age)
```

Context: might fail with an error value.

---

## The Problem: Combining Monads

In our `hask` app, command handlers need to do **both** IO and error handling.
Currently this looks something like:

```haskell
handleAdd :: String -> IO (Either HaskError ())
handleAdd title = do
    notes <- loadNotes "notes.json"    -- IO (Either HaskError [Note])
    case notes of
      Left err -> return (Left err)
      Right ns -> do
        let newNote = makeNote ns title
        result <- saveNotes "notes.json" (ns ++ [newNote])
        case result of
          Left err -> return (Left err)
          Right _  -> return (Right ())
```

See the pattern? Every IO action that can fail forces another `case` expression.
It is nested, repetitive, and hard to read. We are manually threading the
`Either` through `IO`. There must be a better way.

---

## Monad Transformers: Stacking Monads

A **monad transformer** wraps one monad around another, giving you the powers of
both in a single `do` block. The `mtl` library (Monad Transformer Library)
provides the standard transformers.

The naming convention: the transformer version has a `T` suffix.

| Base monad   | Transformer  | Adds                     |
|-------------|-------------|--------------------------|
| `Either e`  | `ExceptT e` | Error handling           |
| `Reader r`  | `ReaderT r` | Shared read-only config  |
| `State s`   | `StateT s`  | Mutable state            |
| `Writer w`  | `WriterT w` | Accumulated output/logs  |

You build a **stack** by nesting transformers, with `IO` (or another base monad)
at the bottom.

---

## ExceptT: Adding Error Handling to IO

`ExceptT` is the transformer version of `Either`. It lets you use `throwError`
and have errors propagate automatically, without manual `case` matching.

```haskell
import Control.Monad.Except

-- ExceptT e m a  means: run in monad m, may fail with error e, success is a
-- ExceptT HaskError IO a  ~  IO (Either HaskError a)
```

Key functions:

```haskell
throwError :: e -> ExceptT e m a           -- throw an error
catchError :: ExceptT e m a                -- catch and recover
           -> (e -> ExceptT e m a)
           -> ExceptT e m a
runExceptT :: ExceptT e m a -> m (Either e a)  -- unwrap the transformer
```

Example -- the same handler, much cleaner:

```haskell
handleAdd :: String -> ExceptT HaskError IO ()
handleAdd title = do
    notes <- loadNotes "notes.json"      -- errors propagate automatically
    let newNote = makeNote notes title
    saveNotes "notes.json" (notes ++ [newNote])
```

No more nested `case`. If `loadNotes` throws an error, the rest of the `do`
block is skipped, just like exceptions in other languages -- but fully
type-safe and explicit in the types.

---

## ReaderT: Adding Shared Configuration

`ReaderT` gives every function in the stack access to a shared, read-only
environment -- no need to pass configuration through every function call.

```haskell
import Control.Monad.Reader

-- ReaderT r m a  means: has access to an environment of type r, runs in monad m
-- ReaderT AppConfig IO a  ~  AppConfig -> IO a
```

Key functions:

```haskell
ask    :: ReaderT r m r        -- get the entire environment
asks   :: (r -> a) -> ReaderT r m a  -- get a field from the environment
runReaderT :: ReaderT r m a -> r -> m a  -- provide the environment and run
```

Example:

```haskell
data AppConfig = AppConfig
  { notesFile :: FilePath
  , verbose   :: Bool
  }

getNotesPath :: ReaderT AppConfig IO FilePath
getNotesPath = asks notesFile

logMsg :: String -> ReaderT AppConfig IO ()
logMsg msg = do
    v <- asks verbose
    when v $ liftIO (putStrLn $ "[DEBUG] " ++ msg)
```

---

## liftIO: Running IO Inside a Transformer Stack

When you are inside a transformer stack, plain `IO` actions do not type-check
directly. You need `liftIO` to "lift" them into the stack:

```haskell
import Control.Monad.IO.Class (liftIO)

example :: ExceptT String IO ()
example = do
    liftIO $ putStrLn "This is an IO action inside ExceptT"
    -- putStrLn alone would be a type error here
```

Rule of thumb: any time you want to call an `IO` function inside your
transformer stack, wrap it with `liftIO`.

---

## Building the App Monad

Now we combine `ExceptT` and `ReaderT` into a single monad for our app:

```haskell
import Control.Monad.Except  (ExceptT, runExceptT, throwError)
import Control.Monad.Reader  (ReaderT, runReaderT, asks)
import Control.Monad.IO.Class (liftIO)

data AppConfig = AppConfig
  { notesFile :: FilePath
  , verbose   :: Bool
  }

type App a = ExceptT HaskError (ReaderT AppConfig IO) a
```

Reading the type from the outside in:

1. **`ExceptT HaskError`** -- may fail with a `HaskError`
2. **`ReaderT AppConfig`** -- has access to an `AppConfig`
3. **`IO`** -- can do IO

### runApp: Unwrapping the Stack

To run an `App` action, you peel off the layers:

```haskell
runApp :: AppConfig -> App a -> IO (Either HaskError a)
runApp config action = runReaderT (runExceptT action) config
```

Order matters: `runExceptT` peels the outer layer, `runReaderT` peels the next.

### Using the App Monad

```haskell
handleAdd :: String -> App ()
handleAdd title = do
    path  <- asks notesFile          -- read config (ReaderT)
    notes <- loadNotes path          -- may fail (ExceptT)
    let newNote = makeNote notes title
    saveNotes path (notes ++ [newNote])  -- may fail (ExceptT)
    liftIO $ putStrLn "Note added."      -- IO action (liftIO)

handleList :: App ()
handleList = do
    path  <- asks notesFile
    notes <- loadNotes path
    liftIO $ mapM_ printNote notes
```

### In Main

```haskell
main :: IO ()
main = do
    opts <- parseOptions
    let config = AppConfig
          { notesFile = optFile opts
          , verbose   = optVerbose opts
          }
    result <- runApp config (dispatch opts)
    case result of
      Left err -> do
        putStrLn (formatError err)
        exitFailure
      Right _ -> return ()
```

---

## Before and After

### Before (IO + manual Either threading)

```haskell
handleDelete :: Int -> IO (Either HaskError ())
handleDelete nid = do
    result <- loadNotes "notes.json"
    case result of
      Left err -> return (Left err)
      Right notes ->
        case findNote nid notes of
          Nothing -> return (Left (NoteNotFound nid))
          Just _  -> do
            let remaining = filter (\n -> noteId n /= nid) notes
            saveResult <- saveNotes "notes.json" remaining
            case saveResult of
              Left err -> return (Left err)
              Right _  -> return (Right ())
```

### After (App monad)

```haskell
handleDelete :: Int -> App ()
handleDelete nid = do
    path  <- asks notesFile
    notes <- loadNotes path
    case findNote nid notes of
      Nothing -> throwError (NoteNotFound nid)
      Just _  -> do
        let remaining = filter (\n -> noteId n /= nid) notes
        saveNotes path remaining
        liftIO $ putStrLn "Note deleted."
```

The transformer stack removes the boilerplate. Errors propagate automatically.
Configuration flows implicitly. IO is explicit with `liftIO`. The code reads
almost like pseudocode.

---

## Helper: throwHaskError

For convenience, define a wrapper:

```haskell
throwHaskError :: HaskError -> App a
throwHaskError = throwError
```

This is just `throwError` with the type pinned down. It can help avoid
ambiguous type errors and makes the intent clearer at call sites.

---

## Summary

| Concept               | What it does                                     |
|-----------------------|--------------------------------------------------|
| Monad                 | Pattern for sequencing context-carrying computations |
| `>>=` (bind)          | Chain monadic computations                       |
| `do` notation         | Syntactic sugar for `>>=`                        |
| `ExceptT e m a`       | Adds error handling (Either) to monad m          |
| `ReaderT r m a`       | Adds read-only environment to monad m            |
| `throwError`          | Throw an error in ExceptT                        |
| `asks`                | Read a field from the ReaderT environment        |
| `liftIO`              | Lift a plain IO action into a transformer stack  |
| `runExceptT`          | Unwrap ExceptT to get `m (Either e a)`           |
| `runReaderT`          | Unwrap ReaderT by providing the environment      |
| `type App a = ...`    | Custom monad combining ExceptT + ReaderT + IO    |
| `runApp`              | Execute an App action and get `IO (Either e a)`  |

Next lesson, we will add tests to our refactored application.
