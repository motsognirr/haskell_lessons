# Lesson 02: Lists & Pattern Matching

## Introduction

Lists are the most fundamental data structure in Haskell. Combined with pattern
matching, they give you an incredibly expressive way to process collections of
data. This lesson covers lists in depth, then introduces pattern matching,
guards, case expressions, and the `Maybe` type.

---

## Lists

### The List Type

In Haskell, a list is a homogeneous collection -- every element must have the
same type. The type of a list of integers is written `[Int]`, a list of
characters is `[Char]`, and so on. In general, a list of elements of type `a`
is written `[a]`.

### Building Lists: The Cons Operator

Lists are built from two constructors:

- `[]` -- the empty list
- `(:)` -- the "cons" operator, which prepends an element to a list

The syntax `[1, 2, 3]` is syntactic sugar. What Haskell actually sees is:

```
1 : 2 : 3 : []
```

The cons operator `(:)` is right-associative, so this is parsed as:

```
1 : (2 : (3 : []))
```

Try it in GHCi:

```haskell
ghci> 1 : 2 : 3 : []
[1,2,3]

ghci> 0 : [1, 2, 3]
[0,1,2,3]

ghci> :type (:)
(:) :: a -> [a] -> [a]
```

Notice that `(:)` takes a single element and a list, and produces a new list.
You cannot cons a list onto a list -- that is what `(++)` is for.

### Strings Are Lists of Characters

In Haskell, `String` is simply a type alias for `[Char]`:

```haskell
ghci> :info String
type String = [Char]

ghci> 'H' : "ello"
"Hello"

ghci> "Hello" ++ " " ++ "World"
"Hello World"

ghci> ['H','e','l','l','o']
"Hello"
```

This means every list function works on strings too.

---

## Common List Operations

Here are the most frequently used list functions. Try each one in GHCi:

### head and tail

```haskell
ghci> head [1, 2, 3]
1

ghci> tail [1, 2, 3]
[2,3]

ghci> head []
*** Exception: Prelude.head: empty list
```

**Warning:** `head` and `tail` are *partial functions* -- they crash on empty
lists. Later in this lesson we will learn how to write safe alternatives using
`Maybe`.

### length and null

```haskell
ghci> length [10, 20, 30]
3

ghci> length []
0

ghci> null []
True

ghci> null [1]
False
```

Use `null` instead of `length xs == 0` -- it is more efficient because it does
not need to traverse the entire list.

### Append (++)

```haskell
ghci> [1, 2] ++ [3, 4]
[1,2,3,4]

ghci> "Hello" ++ " " ++ "World"
"Hello World"
```

Note: `(++)` is O(n) in the length of the left list. Prepending with `(:)` is
O(1).

### reverse

```haskell
ghci> reverse [1, 2, 3, 4, 5]
[5,4,3,2,1]

ghci> reverse "stressed"
"desserts"
```

### take and drop

```haskell
ghci> take 3 [1, 2, 3, 4, 5]
[1,2,3]

ghci> drop 3 [1, 2, 3, 4, 5]
[4,5]

ghci> take 10 [1, 2, 3]
[1,2,3]

ghci> drop 10 [1, 2, 3]
[]
```

`take` and `drop` are safe -- they never crash on short lists.

### elem

```haskell
ghci> elem 3 [1, 2, 3, 4]
True

ghci> elem 5 [1, 2, 3, 4]
False

ghci> 'o' `elem` "Hello"
True
```

Using backticks lets you call a function in infix position, which often reads
more naturally: `3 `elem` [1,2,3]`.

---

## Ranges

Haskell provides a convenient syntax for generating sequences:

```haskell
ghci> [1..10]
[1,2,3,4,5,6,7,8,9,10]

ghci> ['a'..'z']
"abcdefghijklmnopqrstuvwxyz"

ghci> [2,4..20]
[2,4,6,8,10,12,14,16,18,20]

ghci> [1,3..20]
[1,3,5,7,9,11,13,15,17,19]

ghci> [10,9..1]
[10,9,8,7,6,5,4,3,2,1]

ghci> [10..1]
[]
```

The last example is a common gotcha -- to count down you must provide two
elements so Haskell can infer the step.

---

## List Comprehensions

List comprehensions let you generate and filter lists using a concise
mathematical notation. The general form is:

```
[ expression | generator, generator, ..., guard, guard, ... ]
```

### Basic Examples

```haskell
ghci> [x * 2 | x <- [1..10]]
[2,4,6,8,10,12,14,16,18,20]

ghci> [x * 2 | x <- [1..10], even x]
[4,8,12,16,20]

ghci> [x + y | x <- [1,2,3], y <- [10,20]]
[11,21,12,22,13,23]
```

### With Strings

```haskell
ghci> [c | c <- "Hello, World!", c `elem` ['A'..'Z']]
"HW"

ghci> length [c | c <- "some text", c == ' ']
1
```

### Combining Generators and Guards

```haskell
ghci> [(x, y) | x <- [1..5], y <- [1..5], x + y == 6]
[(1,5),(2,4),(3,3),(4,2),(5,1)]
```

---

## Pattern Matching

Pattern matching is one of the most powerful features in Haskell. It lets you
deconstruct values by matching them against patterns.

### Matching on Values

You can define a function with multiple equations, each matching a different
pattern:

```haskell
greet :: String -> String
greet "Alice" = "Hey Alice, good to see you!"
greet "Bob"   = "Hi Bob, how are you?"
greet name    = "Hello, " ++ name ++ "."
```

Haskell tries each equation from top to bottom and uses the first one that
matches.

```haskell
ghci> greet "Alice"
"Hey Alice, good to see you!"

ghci> greet "Charlie"
"Hello, Charlie."
```

### Matching on Constructors

You can pattern match on any data constructor. For booleans:

```haskell
myNot :: Bool -> Bool
myNot True  = False
myNot False = True
```

For tuples:

```haskell
fst' :: (a, b) -> a
fst' (x, _) = x

snd' :: (a, b) -> b
snd' (_, y) = y
```

### Pattern Matching on Lists

Since lists are built from `(:)` and `[]`, you can pattern match on those
constructors:

```haskell
isEmpty :: [a] -> Bool
isEmpty []    = True
isEmpty (_:_) = False

myHead :: [a] -> a
myHead (x:_) = x
myHead []    = error "empty list"

myTail :: [a] -> [a]
myTail (_:xs) = xs
myTail []     = error "empty list"
```

The pattern `(x:xs)` binds `x` to the first element and `xs` to the rest of
the list. This is the fundamental pattern for recursive list processing:

```haskell
mySum :: [Int] -> Int
mySum []     = 0
mySum (x:xs) = x + mySum xs
```

```haskell
ghci> mySum [1, 2, 3, 4, 5]
15
```

You can also match on lists of a specific length:

```haskell
describeList :: [a] -> String
describeList []  = "empty"
describeList [x] = "singleton"       -- same as (x:[])
describeList _   = "longer list"
```

### Wildcards with _

The underscore `_` matches anything but does not bind a name. Use it when you
do not care about a particular part of the pattern:

```haskell
firstOf3 :: (a, b, c) -> a
firstOf3 (x, _, _) = x

headOrDefault :: a -> [a] -> a
headOrDefault def []    = def
headOrDefault _   (x:_) = x
```

---

## Guards

Guards let you add boolean conditions to pattern matches. They are written with
the pipe character `|`:

```haskell
bmiTell :: Double -> String
bmiTell bmi
  | bmi <= 18.5 = "underweight"
  | bmi <= 25.0 = "normal"
  | bmi <= 30.0 = "overweight"
  | otherwise    = "obese"
```

`otherwise` is simply defined as `True` -- it acts as a catch-all.

Guards are evaluated top to bottom, and the first one that is `True` wins:

```haskell
ghci> bmiTell 22.0
"normal"

ghci> bmiTell 31.5
"obese"
```

### Combining Pattern Matching and Guards

```haskell
myCompare :: Ord a => a -> a -> String
myCompare x y
  | x < y    = "less than"
  | x == y   = "equal to"
  | otherwise = "greater than"
```

---

## Case Expressions

A `case` expression lets you do pattern matching inside an expression (not just
at the function definition level):

```haskell
describeList :: [a] -> String
describeList xs = "The list is " ++ case xs of
  []  -> "empty."
  [_] -> "a singleton."
  _   -> "a longer list."
```

```haskell
ghci> describeList []
"The list is empty."

ghci> describeList [1]
"The list is a singleton."

ghci> describeList [1, 2, 3]
"The list is a longer list."
```

In fact, the multiple-equation style of pattern matching is syntactic sugar for
a case expression. These two definitions are equivalent:

```haskell
-- Multiple equations:
myHead (x:_) = x
myHead []    = error "empty"

-- Case expression:
myHead xs = case xs of
  (x:_) -> x
  []    -> error "empty"
```

---

## The Maybe Type

### The Problem with Partial Functions

We saw that `head` crashes on an empty list. Functions that can crash are called
*partial functions* and they are a major source of bugs. In many languages, the
equivalent would return `null`, leading to null pointer exceptions elsewhere.

### Maybe to the Rescue

Haskell has a built-in type called `Maybe` that explicitly represents the
possibility of absence:

```haskell
data Maybe a = Nothing | Just a
```

- `Nothing` means "no value"
- `Just a` means "here is a value"

The type system forces callers to handle both cases -- you cannot accidentally
use a `Nothing` as if it were a value.

### Safe Functions with Maybe

```haskell
safeHead :: [a] -> Maybe a
safeHead []    = Nothing
safeHead (x:_) = Just x

safeLast :: [a] -> Maybe a
safeLast []     = Nothing
safeLast [x]    = Just x
safeLast (_:xs) = safeLast xs
```

```haskell
ghci> safeHead [1, 2, 3]
Just 1

ghci> safeHead []
Nothing

ghci> safeLast [1, 2, 3]
Just 3
```

### Working with Maybe Values

You can pattern match on `Maybe` just like any other type:

```haskell
fromMaybe :: a -> Maybe a -> a
fromMaybe def Nothing  = def
fromMaybe _   (Just x) = x

describeMaybe :: Show a => Maybe a -> String
describeMaybe Nothing  = "Got nothing!"
describeMaybe (Just x) = "Got: " ++ show x
```

```haskell
ghci> fromMaybe 0 (safeHead [1, 2, 3])
1

ghci> fromMaybe 0 (safeHead [])
0

ghci> describeMaybe (Just 42)
"Got: 42"

ghci> describeMaybe Nothing
"Got nothing!"
```

### Why Maybe Is Better Than Null

1. **Explicit in the type:** `Maybe a` tells you at a glance that a function
   might not return a value. With null, you have to read the documentation (if
   it even exists).

2. **Compiler enforced:** If a function returns `Maybe a`, the compiler ensures
   you handle the `Nothing` case. Forgetting to check for null is impossible.

3. **Composable:** Haskell provides tools (`fmap`, `>>=`, `maybe`) to chain
   operations on `Maybe` values without deeply nesting if-checks. We will
   explore these in later lessons.

---

## Putting It All Together

Here is a small program that uses everything from this lesson:

```haskell
module Main where

safeHead :: [a] -> Maybe a
safeHead []    = Nothing
safeHead (x:_) = Just x

classify :: Int -> String
classify n
  | n < 0     = "negative"
  | n == 0    = "zero"
  | even n    = "positive even"
  | otherwise = "positive odd"

doubleOdds :: [Int] -> [Int]
doubleOdds xs = [x * 2 | x <- xs, odd x]

main :: IO ()
main = do
  print (safeHead [10, 20, 30])       -- Just 10
  print (safeHead ([] :: [Int]))       -- Nothing
  putStrLn (classify 7)               -- "positive odd"
  print (doubleOdds [1..10])           -- [2,6,10,14,18]
```

---

## Key Takeaways

- Lists are built from `[]` and `(:)`. The notation `[1,2,3]` is sugar for
  `1:2:3:[]`.
- `String` is `[Char]`, so all list functions work on strings.
- List comprehensions provide a concise way to generate and filter lists.
- Pattern matching deconstructs values by matching on constructors.
- The pattern `(x:xs)` splits a list into its head and tail.
- Guards add boolean conditions to function definitions.
- `case` expressions bring pattern matching into expressions.
- `Maybe` replaces null with a type-safe alternative that the compiler enforces.

---

## Next Steps

Complete the exercises in `exercise.md` to practice these concepts. Focus on
using pattern matching and recursion -- avoid relying on built-in functions when
the exercise asks you to implement something yourself.
