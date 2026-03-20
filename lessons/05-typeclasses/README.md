# Lesson 05: Typeclasses

## Overview

Typeclasses are one of Haskell's most distinctive and powerful features. If you
come from an object-oriented background, you can think of them as interfaces
(Java), protocols (Swift), or traits (Rust) -- but they are more flexible because
you can add new "interface implementations" to existing types without modifying
those types. This lesson teaches you how to use and define typeclasses.

---

## What Is a Typeclass?

A typeclass defines a set of functions that can work on many different types. Any
type that provides implementations for those functions is said to be an
**instance** of that typeclass.

You have already seen typeclasses in action without knowing it. When you wrote:

```
ghci> 3 + 5
8
```

The `+` operator works on `Int`, `Integer`, `Double`, and many other types. It is
defined in the `Num` typeclass. Its type is:

```
ghci> :type (+)
(+) :: Num a => a -> a -> a
```

The part before `=>` is a **type constraint**. It says: "`a` can be any type, as
long as that type is an instance of `Num`."

---

## Standard Typeclasses

Haskell comes with many built-in typeclasses. Here are the most important ones:

### Eq -- Equality

Types whose values can be compared for equality.

```haskell
class Eq a where
  (==) :: a -> a -> Bool
  (/=) :: a -> a -> Bool
```

```
ghci> 5 == 5
True
ghci> "hello" /= "world"
True
```

### Ord -- Ordering

Types whose values can be ordered. Every instance of `Ord` must also be an
instance of `Eq`.

```haskell
class Eq a => Ord a where
  compare :: a -> a -> Ordering   -- LT, EQ, or GT
  (<)     :: a -> a -> Bool
  (<=)    :: a -> a -> Bool
  (>)     :: a -> a -> Bool
  (>=)    :: a -> a -> Bool
  min     :: a -> a -> a
  max     :: a -> a -> a
```

```
ghci> compare 3 5
LT
ghci> max 10 20
20
```

### Show -- Converting to String

Types that can be converted to a human-readable string.

```haskell
class Show a where
  show :: a -> String
```

```
ghci> show 42
"42"
ghci> show True
"True"
ghci> show [1, 2, 3]
"[1,2,3]"
```

### Read -- Parsing from String

The inverse of `Show`. Converts a string back to a value.

```haskell
class Read a where
  read :: String -> a   -- simplified
```

```
ghci> read "42" :: Int
42
ghci> read "True" :: Bool
True
```

You almost always need a type annotation with `read` so Haskell knows what type
to parse into.

### Num -- Numeric Types

```haskell
class Num a where
  (+)         :: a -> a -> a
  (-)         :: a -> a -> a
  (*)         :: a -> a -> a
  negate      :: a -> a
  abs         :: a -> a
  signum      :: a -> a
  fromInteger :: Integer -> a
```

Instances include `Int`, `Integer`, `Double`, `Float`.

### Enum -- Enumerable Types

Types whose values can be enumerated sequentially.

```
ghci> [1..5]
[1,2,3,4,5]
ghci> ['a'..'e']
"abcde"
ghci> succ 'B'
'C'
ghci> pred 5
4
```

### Bounded -- Types with Bounds

Types that have a minimum and maximum value.

```
ghci> minBound :: Int
-9223372036854775808
ghci> maxBound :: Bool
True
ghci> minBound :: Char
'\NUL'
```

---

## Type Constraints

A type constraint restricts a polymorphic type to only those types that are
instances of a given typeclass. You write them before `=>`:

```haskell
-- This function works on any type that supports equality
contains :: Eq a => a -> [a] -> Bool
contains _ []     = False
contains x (y:ys) = x == y || contains x ys
```

Without the `Eq a` constraint, Haskell would not let you use `==` because it
cannot guarantee that `a` supports equality.

### Multiple Constraints

When you need more than one constraint, group them in parentheses:

```haskell
showAndCompare :: (Show a, Ord a) => a -> a -> String
showAndCompare x y =
  show x ++ " is " ++ comparison ++ " " ++ show y
  where
    comparison = case compare x y of
      LT -> "less than"
      EQ -> "equal to"
      GT -> "greater than"
```

---

## Deriving Instances

For many standard typeclasses, Haskell can automatically generate instances using
the `deriving` keyword:

```haskell
data Color = Red | Green | Blue
  deriving (Eq, Ord, Show, Read, Enum, Bounded)
```

```
ghci> Red == Blue
False
ghci> show Green
"Green"
ghci> read "Red" :: Color
Red
ghci> [Red .. Blue]
[Red,Green,Blue]
ghci> minBound :: Color
Red
```

Deriving is convenient, but the generated instances follow simple rules. For
example, `deriving Ord` on a sum type orders constructors by their position in
the definition (so `Red < Green < Blue`). The derived `Show` instance just uses
the constructor name as the string representation.

---

## Manual Instances with the `instance` Keyword

When the derived behavior is not what you want, you write your own instance:

```haskell
data Priority = Low | Medium | High

instance Show Priority where
  show Low    = "[LOW]"
  show Medium = "[MED]"
  show High   = "[!!!]"
```

```
ghci> show High
"[!!!]"
ghci> print Medium
[MED]
```

Note that `print x` is the same as `putStrLn (show x)`.

Here is a manual `Eq` instance:

```haskell
data CaseInsensitiveString = CIS String

instance Eq CaseInsensitiveString where
  (CIS a) == (CIS b) = map toLower a == map toLower b
```

### Rules for Instances

1. You can only define one instance of a typeclass per type (no overlapping
   instances by default).
2. The instance must satisfy the laws of the typeclass. For example, `Eq`
   requires that `==` is reflexive, symmetric, and transitive.
3. If a typeclass has a superclass constraint (like `Eq a => Ord a`), your type
   must have an instance of the superclass too.

---

## Defining Your Own Typeclasses

You define a typeclass with the `class` keyword:

```haskell
class Describable a where
  describe :: a -> String
```

This says: "Any type `a` that is an instance of `Describable` must provide a
`describe` function that takes an `a` and returns a `String`."

Now you can implement it for any type:

```haskell
instance Describable Bool where
  describe True  = "a true value"
  describe False = "a false value"

instance Describable Int where
  describe n
    | n > 0     = "a positive integer"
    | n == 0    = "zero"
    | otherwise = "a negative integer"
```

```
ghci> describe True
"a true value"
ghci> describe (42 :: Int)
"a positive integer"
```

### Default Method Implementations

A typeclass can provide default implementations for its methods. An instance can
override them or use the defaults:

```haskell
class Printable a where
  format :: a -> String
  printIt :: a -> IO ()
  printIt x = putStrLn (format x)   -- default implementation
```

Any type that becomes an instance only needs to implement `format`. It gets
`printIt` for free (but can override it if needed):

```haskell
instance Printable Int where
  format n = "The number " ++ show n

-- printIt is automatically: putStrLn (format x)
```

```
ghci> printIt (42 :: Int)
The number 42
```

### Typeclass with Superclass Constraint

You can require that any instance of your typeclass must also be an instance of
another:

```haskell
class (Show a) => PrettyPrint a where
  prettyPrint :: a -> String
  prettyPrint x = "Pretty: " ++ show x   -- default uses Show
```

This means you can only make a type an instance of `PrettyPrint` if it already
has a `Show` instance.

---

## Comparison to Other Languages

| Concept           | Haskell            | Java              | Go               | Rust             |
|-------------------|--------------------|-------------------|------------------|------------------|
| Definition        | `class`            | `interface`       | `interface`      | `trait`          |
| Implementation    | `instance`         | `implements`      | (implicit)       | `impl Trait for` |
| Add to existing   | Yes (any module)   | No                | Yes              | Yes (orphan rules) |
| Default methods   | Yes                | Yes (Java 8+)     | No               | Yes              |
| Multiple          | Yes (constraints)  | Yes               | Yes              | Yes (bounds)     |
| Inheritance       | Superclass (`=>`)  | `extends`         | Embedding        | Supertraits      |

The key advantage of Haskell's approach:

**You can add instances for types you did not define, in modules you did not
write.** In Java, you cannot make `String` implement your custom interface after
the fact. In Haskell, you can write `instance MyClass String where ...` anywhere.

This is called **retroactive conformance** or the **expression problem** solution.
It means libraries can define types, other libraries can define typeclasses, and a
third library can connect the two.

---

## Practical Example: A Note-Taking App

Let us revisit the `Priority` and `Note` types from Lesson 04 and add typeclass
instances to make them more useful:

```haskell
data Priority = Low | Medium | High
  deriving (Eq, Ord)

data Note = Note
  { noteTitle :: String
  , noteBody  :: String
  , noteTags  :: [String]
  , priority  :: Priority
  }
```

### Custom Show for Priority

Instead of the default `Show` which would give us `"Low"`, `"Medium"`, `"High"`,
we can make it display priority markers:

```haskell
instance Show Priority where
  show Low    = "[LOW]"
  show Medium = "[MED]"
  show High   = "[!!!]"
```

### A Custom Typeclass: Displayable

```haskell
class Displayable a where
  display :: a -> String

instance Displayable Note where
  display note =
    show (priority note)
    ++ " "
    ++ noteTitle note
    ++ " (tags: "
    ++ joinTags (noteTags note)
    ++ ")"
    where
      joinTags []     = ""
      joinTags [t]    = t
      joinTags (t:ts) = t ++ ", " ++ joinTags ts
```

### A Custom Typeclass: Searchable

```haskell
class Searchable a where
  search :: String -> a -> Bool

instance Searchable Note where
  search term note =
    term `isInfixOf` noteTitle note
    || term `isInfixOf` noteBody note
    || any (== term) (noteTags note)
```

---

## FlexibleInstances

By default, Haskell only allows instance heads of the form `instance C (T a b)`
where `T` is a type constructor and `a`, `b` are type variables. If you want to
write an instance for a more specific type like `[Note]` (a list of `Note`
specifically), you need the `FlexibleInstances` language extension:

```haskell
{-# LANGUAGE FlexibleInstances #-}

instance Displayable [Note] where
  display notes = unlines (map display notes)
```

This is a very common and safe extension. You enable it with a pragma at the top
of your file.

---

## Quick Reference

| Concept                | Syntax                                        | Example                             |
|------------------------|-----------------------------------------------|-------------------------------------|
| Type constraint        | `(Class a) => ...`                            | `Eq a => a -> a -> Bool`           |
| Multiple constraints   | `(C1 a, C2 a) => ...`                        | `(Show a, Eq a) => a -> String`    |
| Define typeclass       | `class Name a where ...`                      | `class Printable a where ...`      |
| Define instance        | `instance Name Type where ...`                | `instance Show Priority where ...` |
| Deriving               | `data T = ... deriving (C1, C2)`              | `deriving (Eq, Ord, Show)`         |
| Superclass constraint  | `class (Super a) => Sub a where ...`          | `class (Eq a) => Ord a where ...`  |
| Default method         | Define body in `class` block                  | `printIt x = putStrLn (format x)`  |
| Language extension     | `{-# LANGUAGE ExtName #-}`                    | `{-# LANGUAGE FlexibleInstances #-}` |

---

## Common Pitfalls

1. **Forgetting to derive or instance Eq when you need ==.** If you define a
   custom type and try to compare values with `==`, you will get an error unless
   you have an `Eq` instance.

2. **Using `show` when you want `putStrLn`.** `print x` outputs the `show`
   representation including quotes for strings. Use `putStrLn` for strings you
   want displayed directly.

3. **Orphan instances.** An instance is "orphan" if it is defined in a module
   that defines neither the type nor the typeclass. Orphan instances can cause
   problems and GHC will warn about them. Try to define instances in the same
   module as either the type or the typeclass.

4. **Assuming `deriving` always works.** You can only derive a limited set of
   standard typeclasses. For anything custom, you must write the instance
   manually.

---

## Next Steps

In Lesson 06, we will cover **Modules and Project Structure**, where you will
learn to split your code across multiple files and build a proper Haskell project.

Now head over to [the exercise](exercise.md) to practice what you have learned!
