# Exercise 02: Lists & Pattern Matching

## Goal

Create a file `lessons/02-lists-and-pattern-matching/Main.hs` that implements
several functions using pattern matching, guards, recursion, and the `Maybe`
type.

---

## Functions to Implement

### 1. `myHead :: [a] -> Maybe a`

A safe version of `head` that returns `Nothing` for an empty list and `Just x`
for a non-empty list. Use pattern matching on the list constructors `[]` and
`(x:_)`.

### 2. `myLast :: [a] -> Maybe a`

A safe version of `last` that returns the last element of a list wrapped in
`Just`, or `Nothing` if the list is empty. Use pattern matching and recursion.

Hint: Think about three cases:
- The empty list `[]`
- A singleton list `[x]`
- A list with at least two elements `(_:xs)`

### 3. `countElements :: [a] -> Int`

Count the number of elements in a list **without** using the built-in `length`
function. Use pattern matching and recursion.

### 4. `fizzbuzz :: Int -> String`

The classic FizzBuzz problem for a single number. Use guards to implement the
following rules:

- If the number is divisible by both 3 and 5, return `"FizzBuzz"`
- If the number is divisible by 3 (but not 5), return `"Fizz"`
- If the number is divisible by 5 (but not 3), return `"Buzz"`
- Otherwise, return the number as a string (use `show`)

**Important:** Check the "divisible by both" case first, since guards are
evaluated top to bottom.

---

## The `main` Function

Your `main` function should test all the functions and print results. It must
produce **exactly** the following output:

```
Just 1
Nothing
Just 3
4
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
```

Here is the structure for `main`:

```haskell
main :: IO ()
main = do
  -- Test myHead
  print (myHead [1, 2, 3])            -- Just 1
  print (myHead ([] :: [Int]))         -- Nothing

  -- Test myLast
  print (myLast [1, 2, 3])            -- Just 3

  -- Test countElements
  print (countElements [10, 20, 30, 40])  -- 4

  -- Test fizzbuzz: print fizzbuzz for 1 through 15, one per line
  mapM_ (putStrLn . fizzbuzz) [1..15]
```

---

## How to Build and Run

```bash
cd lessons/02-lists-and-pattern-matching
ghc -o lists Main.hs
./lists
```

---

## Checklist

- [ ] File is named `Main.hs` and located in `lessons/02-lists-and-pattern-matching/`
- [ ] Module is declared as `module Main where`
- [ ] `myHead` uses pattern matching and returns `Maybe a`
- [ ] `myLast` uses pattern matching and recursion, returns `Maybe a`
- [ ] `countElements` uses pattern matching and recursion (no `length`)
- [ ] `fizzbuzz` uses guards and checks divisibility by 15 first
- [ ] Code compiles with no warnings
- [ ] Output matches the expected output exactly
