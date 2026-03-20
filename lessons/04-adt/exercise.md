# Exercise 04: Algebraic Data Types

## Goal

Create the foundational data types for the **hask** CLI note manager and write functions
that operate on those types using pattern matching.

## Instructions

Create the file `lessons/04-adt/Main.hs` with the following.

### 1. Define the `Priority` type

```haskell
data Priority = Low | Medium | High deriving (Show, Eq, Ord)
```

This is a simple sum type (enumeration) with three constructors. Deriving `Ord` means
`Low < Medium < High` based on declaration order.

### 2. Define the `Note` type

```haskell
data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Eq)
```

This is a product type with record syntax. Each field gets an automatic accessor function.

### 3. Define the `NoteAction` type

```haskell
data NoteAction
  = Add Note
  | Delete Int
  | Search String
  | ListAll
  deriving (Show)
```

This is a combined sum + product type. Each constructor carries different data (or none,
in the case of `ListAll`).

### 4. Implement `filterByTag`

```haskell
filterByTag :: String -> [Note] -> [Note]
```

Return only the notes whose `tags` list contains the given string. Hint: use `elem` to
check membership in a list.

### 5. Implement `filterByPriority`

```haskell
filterByPriority :: Priority -> [Note] -> [Note]
```

Return only the notes whose `priority` matches the given value.

### 6. Implement `describeAction`

```haskell
describeAction :: NoteAction -> String
```

Use pattern matching to return a human-readable description:

- `Add note` -> `"Adding note: <title>"` (use the `title` accessor on the note)
- `Delete id` -> `"Deleting note with ID: <id>"`
- `Search term` -> `"Searching for: <term>"`
- `ListAll` -> `"Listing all notes"`

### 7. Write `main`

Your `main` function should:

1. Create three sample notes:
   - Note 1: title "Learn Haskell", tags `["haskell", "programming"]`, priority `High`
   - Note 2: title "Buy groceries", tags `["shopping"]`, priority `Low`
   - Note 3: title "Haskell project", tags `["haskell", "project"]`, priority `Medium`

2. Test `filterByTag`:
   - Filter by tag `"haskell"` and print the count (should be `2`)

3. Test `filterByPriority`:
   - Filter by `High` priority and print the count (should be `1`)

4. Test `describeAction`:
   - Print `describeAction (Add note1)` -- should contain `"Adding"`
   - Print `describeAction (Search "test")` -- should contain `"Searching"`

## Expected Output

Your program should produce output that includes:

```
Notes with tag 'haskell': 2
High priority notes: 1
Adding note: Learn Haskell
Searching for: test
```

The exact format may vary, but the key values (`2`, `1`, `Adding`, `Searching`) must
appear in the output.

## How to Build and Run

```bash
cd lessons/04-adt
ghc -o adt Main.hs
./adt
```

## Hints

- `filter` takes a predicate `(a -> Bool)` and a list `[a]`, returning the elements
  that satisfy the predicate.
- `elem x xs` returns `True` if `x` is in the list `xs`.
- Record accessor functions like `title`, `priority`, and `tags` can be used directly:
  `priority someNote` returns the note's priority.
- `show` converts a value to a `String` (works on any type that derives `Show`).
- `length` returns the number of elements in a list.
