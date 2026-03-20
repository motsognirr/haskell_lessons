# Lesson 03: Recursion & Higher-Order Functions

## Introduction

In imperative languages you loop with `for` and `while`. Haskell has no such
constructs. Instead, **recursion** is the primary looping mechanism, and
**higher-order functions** (HOFs) abstract the most common recursion patterns
so you rarely need to write explicit recursion at all.

This lesson covers both topics in depth.

---

## Part 1: Recursion

### The Basic Pattern

Every recursive function has at least two parts:

1. **Base case** -- the condition under which the function stops calling itself.
2. **Recursive case** -- the function calls itself with a "smaller" argument,
   making progress toward the base case.

```haskell
factorial :: Integer -> Integer
factorial 0 = 1                     -- base case
factorial n = n * factorial (n - 1) -- recursive case
```

Evaluation of `factorial 4`:

```
factorial 4
= 4 * factorial 3
= 4 * (3 * factorial 2)
= 4 * (3 * (2 * factorial 1))
= 4 * (3 * (2 * (1 * factorial 0)))
= 4 * (3 * (2 * (1 * 1)))
= 24
```

### Fibonacci

```haskell
fib :: Integer -> Integer
fib 0 = 0
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)
```

This naive version is exponential in time. We will see how to improve it with
accumulators below.

### Sum of a List

Recursion over lists follows the same pattern -- the base case is the empty
list, and the recursive case processes the head and recurses on the tail.

```haskell
mySum :: [Int] -> Int
mySum []     = 0            -- base case: empty list
mySum (x:xs) = x + mySum xs -- recursive case
```

The pattern `(x:xs)` destructures the list into its first element `x` and the
remaining list `xs`.

### Length of a List

```haskell
myLength :: [a] -> Int
myLength []     = 0
myLength (_:xs) = 1 + myLength xs
```

We use `_` because we do not need the value of the head element.

---

### Tail Recursion and Accumulators

The `factorial` definition above builds up a chain of deferred multiplications
on the stack. In a strict language this would risk a stack overflow for large
inputs. **Tail recursion** avoids this by making the recursive call the very
last operation -- there is nothing left to do after it returns.

We achieve tail recursion by adding an **accumulator** parameter that carries
the intermediate result:

```haskell
factorial' :: Integer -> Integer
factorial' n = go n 1
  where
    go 0 acc = acc
    go k acc = go (k - 1) (k * acc)
```

Evaluation of `factorial' 4`:

```
go 4 1
go 3 4
go 2 12
go 1 24
go 0 24
=> 24
```

No deferred operations -- constant stack space (when compiled with
optimisations).

#### Tail-recursive Fibonacci

```haskell
fib' :: Integer -> Integer
fib' n = go n 0 1
  where
    go 0 a _ = a
    go k a b = go (k - 1) b (a + b)
```

This runs in O(n) time instead of exponential.

#### Tail-recursive sum

```haskell
mySum' :: [Int] -> Int
mySum' xs = go xs 0
  where
    go []     acc = acc
    go (y:ys) acc = go ys (acc + y)
```

> **Note on laziness:** Haskell is lazy by default, so even with tail
> recursion the accumulator may build up unevaluated thunks. Use `seq` or
> bang patterns (`!acc`) to force strict evaluation when needed. The standard
> library's `foldl'` (from `Data.List`) handles this for you.

---

## Part 2: Higher-Order Functions

A **higher-order function** is a function that either:

- takes another function as an argument, or
- returns a function as its result.

You have already seen this idea -- the type `(a -> b) -> [a] -> [b]` takes a
function `(a -> b)` as its first argument.

### map

`map` applies a function to every element of a list.

```haskell
map :: (a -> b) -> [a] -> [b]
map _ []     = []
map f (x:xs) = f x : map f xs
```

Examples:

```haskell
map (+1)    [1, 2, 3]    -- [2, 3, 4]
map show    [1, 2, 3]    -- ["1", "2", "3"]
map (*2)    [10, 20, 30] -- [20, 40, 60]
map toUpper "hello"      -- "HELLO"
```

### filter

`filter` keeps only the elements that satisfy a predicate.

```haskell
filter :: (a -> Bool) -> [a] -> [a]
filter _ []     = []
filter p (x:xs)
  | p x       = x : filter p xs
  | otherwise  = filter p xs
```

Examples:

```haskell
filter even    [1..10]  -- [2, 4, 6, 8, 10]
filter (> 3)   [1..5]   -- [4, 5]
filter (/= ' ') "h e l l o" -- "hello"
```

### foldr -- Fold from the Right

`foldr` replaces every `(:)` in a list with a function and `[]` with an
initial value.

```haskell
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr _ z []     = z
foldr f z (x:xs) = f x (foldr f z xs)
```

Conceptually, for `foldr f z [1, 2, 3]`:

```
    :                       f
   / \                     / \
  1   :         =>        1   f
     / \                     / \
    2   :                   2   f
       / \                     / \
      3  []                   3   z
```

Examples:

```haskell
foldr (+) 0 [1, 2, 3]  -- 1 + (2 + (3 + 0)) = 6
foldr (*) 1 [1, 2, 3]  -- 1 * (2 * (3 * 1)) = 6
foldr (:) [] [1, 2, 3] -- 1 : (2 : (3 : [])) = [1, 2, 3]  (identity!)
```

### foldl -- Fold from the Left

`foldl` processes the list from left to right, threading an accumulator.

```haskell
foldl :: (b -> a -> b) -> b -> [a] -> b
foldl _ z []     = z
foldl f z (x:xs) = foldl f (f z x) xs
```

For `foldl f z [1, 2, 3]`:

```
          f
         / \
        f   3
       / \
      f   2
     / \
    z   1
```

Evaluation:

```
foldl (+) 0 [1, 2, 3]
= foldl (+) (0 + 1) [2, 3]
= foldl (+) ((0 + 1) + 2) [3]
= foldl (+) (((0 + 1) + 2) + 3) []
= ((0 + 1) + 2) + 3
= 6
```

### foldl vs foldr -- When to Use Which

| Property             | `foldr`                          | `foldl`                         |
|----------------------|----------------------------------|---------------------------------|
| Association          | Right: `1 + (2 + (3 + z))`      | Left: `((z + 1) + 2) + 3`      |
| Works on infinite lists? | Yes (if `f` is lazy in 2nd arg) | No                           |
| Tail recursive?      | No                               | Yes (but beware thunks)         |
| Strict variant       | N/A                              | `foldl'` from `Data.List`      |
| Build a list?        | Good choice (preserves order)    | Reverses the list               |
| Arithmetic sums?     | Works but not ideal              | Use `foldl'` for efficiency     |

**Rule of thumb:** Use `foldr` when building data structures or when the
combining function may short-circuit. Use `foldl'` (strict left fold) for
arithmetic reductions.

---

## Part 3: Lambda Expressions

A **lambda expression** (anonymous function) is written with a backslash:

```haskell
\x -> x + 1        -- a function that adds 1
\x y -> x + y      -- a function that adds two numbers
\(x, y) -> x + y   -- a function on a tuple
```

Lambdas are useful when you need a short function that is not worth naming:

```haskell
map (\x -> x * x) [1, 2, 3]      -- [1, 4, 9]
filter (\x -> x `mod` 3 == 0) [1..10]  -- [3, 6, 9]
```

However, prefer named helper functions or sections when they are clearer:

```haskell
map (^2) [1, 2, 3]  -- [1, 4, 9]  (section, cleaner than lambda)
```

---

## Part 4: Function Composition and Application

### The (.) operator -- Function Composition

`(.)` composes two functions:

```haskell
(.) :: (b -> c) -> (a -> b) -> a -> c
(f . g) x = f (g x)
```

Read `f . g` as "f after g". The output of `g` is fed into `f`.

```haskell
doubleAndShow :: Int -> String
doubleAndShow = show . (*2)

doubleAndShow 5  -- "10"
```

Composition chains read right-to-left:

```haskell
process :: [Int] -> [Int]
process = filter even . map (+1) . filter (> 0)
-- 1. keep positives
-- 2. add 1 to each
-- 3. keep evens
```

### The ($) operator -- Function Application

`($)` is just function application, but with the lowest precedence and
right-associative. It eliminates parentheses:

```haskell
($) :: (a -> b) -> a -> b
f $ x = f x
```

Compare:

```haskell
putStrLn (show (1 + 2))   -- with parentheses
putStrLn $ show $ 1 + 2   -- with ($)
```

Both produce `"3"`. The `$` version often reads more cleanly.

### Combining (.) and ($)

A common idiom:

```haskell
putStrLn . show $ filter even [1..10]
-- equivalent to: putStrLn (show (filter even [1..10]))
```

Use `(.)` to build a pipeline of transformations, then `($)` to apply it to
an argument.

---

## Part 5: Currying and Partial Application

Every function in Haskell takes exactly **one** argument. A function that
appears to take two arguments is actually a function that takes one argument
and returns a new function:

```haskell
add :: Int -> Int -> Int
add x y = x + y
```

This is the same as:

```haskell
add :: Int -> (Int -> Int)
add = \x -> \y -> x + y
```

**Partial application** means supplying fewer arguments than a function
expects, yielding a new function:

```haskell
addThree :: Int -> Int
addThree = add 3

addThree 10  -- 13
```

This is why `map (+1) [1,2,3]` works: `(+1)` is the `(+)` function partially
applied to `1`.

### Sections

Operator sections are partial applications of infix operators:

```haskell
(+1)   -- \x -> x + 1
(2*)   -- \x -> 2 * x
(/2)   -- \x -> x / 2
(>3)   -- \x -> x > 3
```

---

## Part 6: From Imperative Loops to Haskell HOFs

Here are common imperative patterns and their Haskell equivalents.

### Transform every element (for-each + modify)

Python:
```python
result = []
for x in xs:
    result.append(x * 2)
```

Haskell:
```haskell
result = map (*2) xs
```

### Keep some elements (for-each + if)

Python:
```python
result = []
for x in xs:
    if x % 2 == 0:
        result.append(x)
```

Haskell:
```haskell
result = filter even xs
```

### Reduce to a single value (accumulator loop)

Python:
```python
total = 0
for x in xs:
    total += x
```

Haskell:
```haskell
total = foldl (+) 0 xs
```

### Chaining operations (pipeline)

Python:
```python
result = sum(x**2 for x in xs if x > 0)
```

Haskell:
```haskell
result = sum . map (^2) . filter (> 0) $ xs
```

---

## Summary

| Concept                    | Key Idea                                         |
|----------------------------|--------------------------------------------------|
| Recursion                  | Base case + recursive case replaces loops         |
| Tail recursion             | Accumulator parameter, last action is the call    |
| `map`                      | Apply a function to every element                 |
| `filter`                   | Keep elements satisfying a predicate              |
| `foldr`                    | Collapse a list right-to-left                     |
| `foldl` / `foldl'`        | Collapse a list left-to-right (use strict `foldl'`) |
| Lambda `\x -> ...`        | Anonymous function                                |
| Composition `f . g`       | Pipeline: apply `g` then `f`                      |
| Application `f $ x`       | Low-precedence application (reduces parens)       |
| Currying                   | Every function takes one arg, returns a function  |
| Partial application        | Supply fewer args to get a specialised function   |

With these tools you can express almost any data-transformation pipeline
concisely and declaratively. In the exercises you will implement `map`,
`filter`, and `foldl` from scratch, then use the standard versions to write
elegant one-liners.
