# Lesson 01: Types & Functions

## Overview

This lesson covers the foundation of Haskell programming: its type system and how
to define functions. If you come from Python, JavaScript, or similar languages,
Haskell's approach to types will feel very different -- and once it clicks, you
will wonder how you ever lived without it.

---

## Haskell's Type System

Haskell's type system has three key properties:

### Strong

Haskell will never silently coerce one type into another. You cannot add an `Int`
to a `Double` without explicitly converting one of them. This catches a huge class
of bugs at compile time.

```haskell
-- This will NOT compile:
-- 3 + 2.5        -- ambiguous, but Haskell resolves numeric literals specially
-- (3 :: Int) + (2.5 :: Double)   -- ERROR: no implicit conversion
```

### Static

Every expression has a type known at compile time. The compiler checks all types
before your program ever runs. If it compiles, a whole category of runtime errors
simply cannot happen.

### Inferred

You rarely *need* to write type annotations -- the compiler can figure them out.
But you *should* write them anyway, because:

- They serve as documentation
- They help you think about your design
- They produce better error messages when something goes wrong

---

## Basic Types

Fire up `ghci` (the Haskell REPL) and follow along:

```
$ ghci
```

### Numeric Types

| Type      | Description                          | Example       |
|-----------|--------------------------------------|---------------|
| `Int`     | Fixed-precision integer (at least 30 bits) | `42`    |
| `Integer` | Arbitrary-precision integer          | `123456789012345` |
| `Double`  | Double-precision floating point      | `3.14`        |
| `Float`   | Single-precision floating point      | `2.71`        |

```
ghci> :type 42
42 :: Num a => a

ghci> :type (42 :: Int)
(42 :: Int) :: Int

ghci> :type (42 :: Integer)
(42 :: Integer) :: Integer

ghci> :type 3.14
3.14 :: Fractional a => a

ghci> :type (3.14 :: Double)
(3.14 :: Double) :: Double
```

Note how bare numeric literals like `42` have a polymorphic type (`Num a => a`).
Haskell will pick a concrete type based on context. Do not worry about the `=>`
syntax yet -- we will cover type classes in a later lesson.

### Bool

```
ghci> :type True
True :: Bool

ghci> :type False
False :: Bool

ghci> True && False
False

ghci> True || False
True

ghci> not True
False
```

### Char and String

A `Char` is a single character, written with single quotes. A `String` is a list
of characters, written with double quotes.

```
ghci> :type 'a'
'a' :: Char

ghci> :type "hello"
"hello" :: String

ghci> :info String
type String = [Char]    -- String is just a type alias for [Char]
```

This is important: `String` is literally `[Char]` -- a list of characters. This
makes strings easy to work with using list functions, but it is not the most
efficient representation. (For performance-critical code, you would use `Text`
from the `text` package, but `String` is fine for learning.)

```
ghci> head "hello"
'h'

ghci> tail "hello"
"ello"

ghci> length "hello"
5

ghci> 'h' : "ello"
"hello"

ghci> "hello" ++ " world"
"hello world"
```

---

## Type Signatures

In Haskell, you declare the type of a function on a separate line above its
definition, using `::` (read as "has type"):

```haskell
double :: Int -> Int
double x = x * 2
```

Read `Int -> Int` as: "takes an `Int` and returns an `Int`."

Try it in ghci:

```
ghci> double x = x * 2
ghci> :type double
double :: Num a => a -> a
```

When you do not write a type signature, Haskell infers the most general type.
Here it infers `Num a => a -> a` (works for any numeric type). If you write
`double :: Int -> Int`, you pin it down to `Int` only.

**Best practice:** Always write type signatures for top-level definitions.

---

## Defining Functions

Functions in Haskell look different from most languages:

- No parentheses around arguments
- No commas between arguments
- No `return` keyword -- the entire body is an expression whose value is returned

```haskell
add :: Int -> Int -> Int
add x y = x + y
```

Call it:

```
ghci> add 3 5
8
```

Not `add(3, 5)`. Just `add 3 5`. Function application is written with spaces.

Function application has the highest precedence, so:

```
ghci> add 3 5 * 2
16

ghci> add 3 (5 * 2)
13
```

In the first example, `add 3 5` is evaluated first (giving `8`), then `8 * 2`.
Use parentheses when you need to change the order.

### More Examples

```haskell
-- A function with no arguments is just a value (a constant)
greeting :: String
greeting = "Hello, world!"

-- Using built-in functions
isEven :: Int -> Bool
isEven n = n `mod` 2 == 0

-- Absolute value (using if/then/else, covered below)
absolute :: Int -> Int
absolute n = if n < 0 then -n else n
```

---

## Multi-Argument Functions and Currying

Look at this type signature again:

```haskell
add :: Int -> Int -> Int
```

The `->` arrow is right-associative, so this actually means:

```haskell
add :: Int -> (Int -> Int)
```

Read it as: `add` takes an `Int` and returns a *function* that takes an `Int` and
returns an `Int`. This is called **currying**.

This means you can partially apply functions:

```
ghci> add x y = x + y
ghci> addThree = add 3
ghci> addThree 5
8
ghci> addThree 10
13
ghci> :type addThree
addThree :: Int -> Int
```

`add 3` gives you back a new function that adds 3 to its argument. Every
multi-argument function in Haskell works this way -- it is always a chain of
single-argument functions.

This is incredibly useful for higher-order programming (covered in a later lesson),
but for now just understand the notation.

---

## Where Clauses

A `where` clause lets you define local bindings after the main expression:

```haskell
circleArea :: Double -> Double
circleArea radius = pi * radius ^ 2
  where
    pi = 3.14159265

bmi :: Double -> Double -> String
bmi weight height
  | bmiValue < 18.5 = "underweight"
  | bmiValue < 25.0 = "normal"
  | bmiValue < 30.0 = "overweight"
  | otherwise        = "obese"
  where
    bmiValue = weight / height ^ 2
```

The `where` block is indented and can contain multiple definitions. The bindings
are in scope for the entire right-hand side of the equation (including guards,
which we will cover in a later lesson).

---

## Let...In Expressions

`let...in` is similar to `where`, but it is an expression -- you can use it
anywhere an expression is expected:

```haskell
cylinderVolume :: Double -> Double -> Double
cylinderVolume radius height =
  let baseArea = 3.14159265 * radius ^ 2
      sideArea = 2 * 3.14159265 * radius * height
  in  baseArea * height
```

In ghci, `let` works without `in`:

```
ghci> let x = 5 in x * 2
10

ghci> let a = 3; b = 4 in a + b
7
```

### Where vs Let

- `where` is a syntactic construct attached to a definition; `let...in` is an
  expression.
- Use `where` when you want helpers visible across guards or multiple equations.
- Use `let...in` when you need a local binding inside an expression.
- Both are common; use whichever reads better in context.

---

## Tuples

A tuple groups a fixed number of values of possibly different types:

```
ghci> :type (1, "hello")
(1, "hello") :: (Num a) => (a, String)

ghci> :type (True, 'a', 42)
(True, 'a', 42) :: Num c => (Bool, Char, c)
```

For pairs (2-tuples), you can use `fst` and `snd`:

```
ghci> fst (1, "hello")
1

ghci> snd (1, "hello")
"hello"
```

`fst` and `snd` only work on pairs, not on larger tuples.

Tuples are useful for returning multiple values from a function:

```haskell
divMod' :: Int -> Int -> (Int, Int)
divMod' x y = (x `div` y, x `mod` y)
```

```
ghci> divMod' 17 5
(3,2)
```

**Note:** Tuple types are defined by their size. `(Int, String)` and
`(Int, String, Bool)` are completely different types. You cannot mix them up.

---

## Type Inference

Haskell can figure out most types on its own:

```haskell
-- No type signature needed -- Haskell infers it
double x = x * 2
-- Inferred: double :: Num a => a -> a

-- But ALWAYS write signatures for top-level functions:
double :: Num a => a -> a
double x = x * 2
```

When you are experimenting in ghci, you can check what the compiler infers:

```
ghci> :type map
map :: (a -> b) -> [a] -> [b]

ghci> :type (&&)
(&&) :: Bool -> Bool -> Bool

ghci> let f x y = x + y
ghci> :type f
f :: Num a => a -> a -> a
```

---

## If / Then / Else

In Haskell, `if/then/else` is an **expression**, not a statement. It always
returns a value, and the `else` branch is mandatory.

```haskell
absolute :: Int -> Int
absolute n = if n < 0 then -n else n
```

```
ghci> if True then "yes" else "no"
"yes"

ghci> if 3 > 5 then "big" else "small"
"small"
```

Both branches must have the same type:

```
ghci> if True then 1 else "hello"
-- ERROR: different types in branches
```

You can nest them, but it gets ugly fast. For more complex branching, use guards
or pattern matching (covered in lesson 02).

```haskell
classifyTemp :: Double -> String
classifyTemp temp =
  if temp < 0
    then "freezing"
    else if temp < 20
      then "cold"
      else if temp < 30
        then "warm"
        else "hot"
```

---

## Putting It All Together

Here is a small complete program that uses everything from this lesson:

```haskell
module Main where

-- Type signature: takes a Double, returns a Double
celsiusToFahrenheit :: Double -> Double
celsiusToFahrenheit c = c * 9 / 5 + 32

-- Multi-argument function
greet :: String -> String -> String
greet firstName lastName = "Hello, " ++ firstName ++ " " ++ lastName ++ "!"

-- Using where
bmiCategory :: Double -> Double -> String
bmiCategory weight height = if bmi < 18.5
                            then "underweight"
                            else if bmi < 25.0
                              then "normal"
                              else "overweight"
  where
    bmi = weight / (height ^ 2)

-- Tuples
swap :: (a, b) -> (b, a)
swap (x, y) = (y, x)

main :: IO ()
main = do
  putStrLn (greet "Haskell" "Learner")
  print (celsiusToFahrenheit 100)
  print (swap (1, "hello"))
```

Save this as `Example.hs` and run it:

```
$ ghc -o example Example.hs
$ ./example
Hello, Haskell Learner!
212.0
("hello",1)
```

---

## Quick Reference

| Concept             | Syntax                              | Example                        |
|---------------------|-------------------------------------|--------------------------------|
| Type signature      | `name :: Type`                      | `f :: Int -> Bool`             |
| Function definition | `name args = body`                  | `add x y = x + y`             |
| Where clause        | `expr where bindings`               | `f x = y * 2 where y = x + 1` |
| Let expression      | `let bindings in expr`              | `let x = 5 in x * 2`          |
| Tuple               | `(a, b)`                            | `(1, "hi")`                    |
| If expression       | `if cond then a else b`             | `if x > 0 then x else -x`     |
| String concat       | `++`                                | `"hi" ++ " there"`            |
| Check type in ghci  | `:type expr` or `:t expr`           | `:t not`                       |

---

## Next Steps

In Lesson 02, we will cover **Pattern Matching & Guards**, which give you much
more elegant ways to branch and destructure data than `if/then/else`.

Now head over to [the exercise](exercise.md) to practice what you have learned!
