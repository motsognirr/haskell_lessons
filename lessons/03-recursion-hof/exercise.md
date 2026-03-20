# Lesson 03 -- Exercise: Recursion & Higher-Order Functions

## Goal

Create the file `lessons/03-recursion-hof/Main.hs` that implements several
functions and prints test results.

---

## Part 1: Implement From Scratch

Implement the following functions **without** using the Prelude versions
(`map`, `filter`, `foldl`). Use explicit recursion with pattern matching.

### myMap

```haskell
myMap :: (a -> b) -> [a] -> [b]
```

Apply a function to every element of a list.

### myFilter

```haskell
myFilter :: (a -> Bool) -> [a] -> [a]
```

Keep only elements for which the predicate returns `True`.

### myFoldl

```haskell
myFoldl :: (b -> a -> b) -> b -> [a] -> b
```

Fold a list from the left using a combining function and a starting
accumulator value.

---

## Part 2: One-Liners Using Standard HOFs

Using the standard `map`, `filter`, `foldl` (or `foldr`, `sum`, etc.),
implement each of these as a single expression (one-liner).

### doubleAll

```haskell
doubleAll :: [Int] -> [Int]
```

Double every element in the list.

### keepEvens

```haskell
keepEvens :: [Int] -> [Int]
```

Keep only the even numbers.

### sumSquares

```haskell
sumSquares :: [Int] -> Int
```

Compute the sum of the squares of all elements.

---

## Part 3: main

Your `main` function should print the following test results, one per line:

```
myMap (+1) [1,2,3] = [2,3,4]
myFilter even [1,2,3,4,5] = [2,4]
myFoldl (+) 0 [1,2,3,4,5] = 15
doubleAll [1,2,3] = [2,4,6]
keepEvens [1,2,3,4,5,6] = [2,4,6]
sumSquares [1,2,3] = 14
```

Use `show` to convert results to strings and `putStrLn` to print them.

For example:

```haskell
putStrLn $ "myMap (+1) [1,2,3] = " ++ show (myMap (+1) [1,2,3])
```

---

## Hints

- For `myMap` and `myFilter`, pattern match on `[]` and `(x:xs)`.
- For `myFoldl`, the base case is when the list is empty -- return the
  accumulator. The recursive case applies the function to the accumulator and
  the head, then recurses on the tail.
- `doubleAll` can use `map` with a section or lambda.
- `keepEvens` can use `filter` with `even`.
- `sumSquares` can combine `map` and `sum`, or use `foldl`.

---

## Testing

Compile and run:

```bash
cd lessons/03-recursion-hof
ghc -o hof Main.hs
./hof
```

Expected output:

```
myMap (+1) [1,2,3] = [2,3,4]
myFilter even [1,2,3,4,5] = [2,4]
myFoldl (+) 0 [1,2,3,4,5] = 15
doubleAll [1,2,3] = [2,4,6]
keepEvens [1,2,3,4,5,6] = [2,4,6]
sumSquares [1,2,3] = 14
```
