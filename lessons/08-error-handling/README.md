# Lesson 08: Error Handling

## The Problem with Exceptions

In many languages, errors are handled with exceptions. Haskell *does* support
exceptions, but they have serious drawbacks:

1. **They are impure.** Throwing an exception is a side effect. A function
   `divide :: Int -> Int -> Int` that throws on division by zero is *lying*
   about its type -- it does not always return an `Int`.

2. **They are unchecked.** Nothing in the type signature tells the caller that
   a function might fail. You have to read the documentation (or the source)
   to find out.

3. **They break equational reasoning.** If any sub-expression can secretly
   explode, you can no longer reason about code by substituting equals for
   equals.

Haskell's answer: **encode failure in the type system** so the compiler forces
you to handle it.

---

## Maybe: Something or Nothing

The simplest error-handling type is `Maybe`:

```haskell
data Maybe a = Nothing | Just a
```

A function that *might* not produce a result returns `Maybe`:

```haskell
safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing
safeDivide x y = Just (x `div` y)

lookupById :: Int -> [Note] -> Maybe Note
lookupById _  []     = Nothing
lookupById i  (n:ns)
  | noteId n == i    = Just n
  | otherwise        = lookupById i ns
```

The caller is *forced* to handle both cases:

```haskell
case safeDivide 10 0 of
  Nothing -> putStrLn "Cannot divide by zero"
  Just n  -> putStrLn ("Result: " ++ show n)
```

### When to Use Maybe

- The function can fail in **exactly one obvious way** (not found, empty
  input, out of range...)
- The caller does not need to know *why* it failed -- only *that* it failed.

---

## Either: Failure with a Reason

Often we want to know *what* went wrong. That is what `Either` is for:

```haskell
data Either a b = Left a | Right b
```

By convention:

- `Left` carries the **error** value
- `Right` carries the **success** value

Mnemonic: **"Right" means correct.**

```haskell
safeDivide :: Int -> Int -> Either String Int
safeDivide _ 0 = Left "Division by zero"
safeDivide x y = Right (x `div` y)
```

```haskell
parseAge :: String -> Either String Int
parseAge s = case reads s of
  [(n, "")] | n >= 0 && n < 150 -> Right n
  _                              -> Left ("Invalid age: " ++ show s)
```

The caller pattern-matches on `Left`/`Right`:

```haskell
case parseAge input of
  Left  err -> putStrLn ("Error: " ++ err)
  Right age -> putStrLn ("You are " ++ show age ++ " years old")
```

---

## Chaining with Case Matching

Real programs often have multiple steps that can each fail. Chaining with
explicit `case` works but gets nested quickly:

```haskell
processNote :: String -> String -> Either String Note
processNote rawId rawTitle =
  case parseAge rawId of          -- reusing parseAge as an example
    Left err -> Left err
    Right id_ ->
      case validateTitle rawTitle of
        Left err    -> Left err
        Right title -> Right (Note id_ title "" [] Medium)
```

This "staircase of doom" is tedious. Fortunately, Haskell has a better way.

---

## The >>= Operator (Monadic Bind)

Both `Maybe` and `Either e` support the `>>=` operator (pronounced "bind"):

```haskell
(>>=) :: Maybe a    -> (a -> Maybe b)    -> Maybe b
(>>=) :: Either e a -> (a -> Either e b) -> Either e b
```

It works like this: if the left side is a failure (`Nothing` or `Left e`),
the whole expression is that same failure. If the left side is a success
(`Just a` or `Right a`), unwrap the value and pass it to the function on
the right.

```haskell
-- Maybe example
safeDivide 10 2 >>= \result -> safeLookup result table
-- If safeDivide returns Nothing, the whole thing is Nothing.
-- If it returns Just 5, then safeLookup 5 table runs next.
```

```haskell
-- Either example
parseInt rawId >>= \id_ ->
validateTitle rawTitle >>= \title ->
Right (Note id_ title "" [] Medium)
```

This eliminates the staircase. We will cover monads properly in a later
lesson -- for now, just know that `>>=` chains computations that can fail,
short-circuiting on the first error.

**Do-notation** (syntactic sugar for `>>=`) works too:

```haskell
processNote :: String -> String -> Either String Note
processNote rawId rawTitle = do
  id_   <- parseInt rawId
  title <- validateTitle rawTitle
  Right (Note id_ title "" [] Medium)
```

---

## Custom Error Types

Using `String` for errors is fine for scripts, but real applications benefit
from a dedicated error type:

```haskell
data AppError
  = NotFound Int
  | ParseError String
  | StorageError String
  deriving (Show, Eq)
```

Why?

1. **Pattern matching** -- you can handle each error case differently.
2. **Exhaustiveness checking** -- the compiler warns if you forget a case.
3. **Composability** -- functions throughout the app speak the same error
   language.

### Formatting Errors for Users

Pattern match to produce user-friendly messages:

```haskell
formatError :: AppError -> String
formatError (NotFound i)      = "Error: item " ++ show i ++ " not found."
formatError (ParseError msg)  = "Parse error: " ++ msg
formatError (StorageError msg) = "Storage error: " ++ msg
```

Then in your main function:

```haskell
case result of
  Left err -> putStrLn (formatError err)
  Right _  -> pure ()
```

---

## Converting Between Maybe and Either

Sometimes a library gives you `Maybe` but you need `Either`, or vice versa.

### Maybe to Either

```haskell
maybeToEither :: e -> Maybe a -> Either e a
maybeToEither err Nothing  = Left err
maybeToEither _   (Just x) = Right x
```

Usage:

```haskell
lookupNote :: Int -> [Note] -> Either AppError Note
lookupNote i notes = maybeToEither (NotFound i) (find (\n -> noteId n == i) notes)
```

### Either to Maybe

```haskell
eitherToMaybe :: Either e a -> Maybe a
eitherToMaybe (Left _)  = Nothing
eitherToMaybe (Right x) = Just x
```

This deliberately discards the error information, so use it only when you
truly do not care about the reason for failure.

---

## When to Use What

| Mechanism   | Use when...                                           |
|-------------|-------------------------------------------------------|
| `Maybe`     | Failure is obvious, caller does not need a reason     |
| `Either`    | Caller needs to know *what* went wrong                |
| Custom type | App has multiple distinct failure modes                |
| Exceptions  | Truly exceptional situations (out of memory, bug)     |

Rule of thumb: **prefer `Maybe`/`Either` for expected failures** (missing
record, bad input, file not found). Reserve exceptions for things you
genuinely cannot recover from.

---

## Partial vs Total Functions

A **partial function** is one that does not handle all possible inputs:

```haskell
head :: [a] -> a        -- crashes on []
fromJust :: Maybe a -> a -- crashes on Nothing
read :: String -> a      -- crashes on unparseable input
```

A **total function** handles every input:

```haskell
safeHead :: [a] -> Maybe a
safeHead []    = Nothing
safeHead (x:_) = Just x
```

When refactoring, the goal is to **turn partial functions into total
functions** by using `Maybe` or `Either` as the return type. This pushes
error handling to the edges of your program (usually `main`), keeping the
core logic pure and safe.

---

## Practical Pattern: Error Handling at the Edges

A well-structured Haskell application looks like this:

```
main (IO, handles errors, prints messages)
  |
  +-- pure business logic (returns Either AppError result)
        |
        +-- pure helpers (total functions, no exceptions)
```

The inner functions never print, never crash, never throw. They return
`Either AppError a`. The outer `main` function is the only place that
pattern-matches on `Left`/`Right` and decides what to show the user.

---

## Summary

- **`Maybe a`** = might have a value, might not. Use when failure reason is
  obvious.
- **`Either e a`** = success (`Right a`) or failure with info (`Left e`).
  Mnemonic: "right" is correct.
- **`>>=` (bind)** chains failable computations, short-circuiting on first
  error.
- **Custom error types** give you exhaustive pattern matching and
  user-friendly messages.
- **Convert** between `Maybe` and `Either` with simple helper functions.
- **Prefer total functions** -- push `Maybe`/`Either` to the return type
  instead of crashing.
- **Handle errors at the edges** (in `main`), keep the core pure.

Next exercise: you will add a custom `HaskError` type to the `hask` app and
refactor the storage and command handling to use `Either` instead of crashing.
