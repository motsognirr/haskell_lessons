# Lesson 04: Algebraic Data Types

Algebraic Data Types (ADTs) are one of Haskell's most powerful features. They let you
define your own types that precisely model your problem domain. If you have used enums,
classes, or structs in other languages, ADTs unify all of those ideas into a single,
elegant mechanism.

This lesson is also where we begin designing the data model for **hask**, the CLI note
manager you will build throughout the rest of this course.

---

## 1. The `data` Keyword

You create a new type in Haskell with the `data` keyword:

```haskell
data MyType = MyConstructor
```

- **MyType** is the *type name* (used in type signatures).
- **MyConstructor** is a *data constructor* (used to create values of that type).

Both must start with an uppercase letter.

---

## 2. Sum Types (Enumerations)

A sum type offers a choice between several alternatives, separated by `|` (read as "or"):

```haskell
data Color = Red | Green | Blue
```

A value of type `Color` is exactly one of `Red`, `Green`, or `Blue` -- nothing else.
This is similar to an `enum` in C, Java, TypeScript, or Rust.

```haskell
favorite :: Color
favorite = Blue
```

### Why "sum"?

The total number of possible values is the *sum* of the values each constructor can
produce: 1 + 1 + 1 = 3.

---

## 3. Product Types (Records)

A product type bundles multiple pieces of data together, like a struct or a class with
fields:

```haskell
data Person = Person String Int
```

Here `Person` appears twice -- once as the type name (left of `=`) and once as the data
constructor (right of `=`). They live in different namespaces, so this is perfectly fine
and very common in Haskell.

You create a value by applying the constructor to arguments:

```haskell
alice :: Person
alice = Person "Alice" 30
```

### Why "product"?

The number of possible values is the *product* of the possibilities for each field.
If `String` has S possible values and `Int` has I possible values, then `Person` has
S * I possible values.

---

## 4. Record Syntax

Plain positional fields are hard to read once you have more than two or three. Record
syntax gives each field a name:

```haskell
data Person = Person
  { name :: String
  , age  :: Int
  } deriving (Show)
```

This automatically generates **accessor functions**:

```haskell
name :: Person -> String
age  :: Person -> Int
```

You can construct values with named fields (in any order):

```haskell
bob :: Person
bob = Person { name = "Bob", age = 25 }
```

And you can update a record by copying with changes:

```haskell
olderBob :: Person
olderBob = bob { age = 26 }
```

This does not mutate `bob` -- it creates a brand-new `Person` value. Haskell values are
always immutable.

---

## 5. Combined Sum + Product Types

The real power of ADTs comes from combining sum and product types. Each constructor in a
sum type can carry its own set of fields:

```haskell
data Shape
  = Circle    { radius :: Double }
  | Rectangle { width :: Double, height :: Double }
  | Triangle  { sideA :: Double, sideB :: Double, sideC :: Double }
```

A `Shape` value is *either* a `Circle` with a radius, *or* a `Rectangle` with a width
and height, *or* a `Triangle` with three sides. There is no way to create a `Shape`
that is somehow half-circle, half-triangle.

This is what other languages try to approximate with class hierarchies, tagged unions,
or sealed interfaces. In Haskell it is built into the type system.

### Example: computing area

```haskell
area :: Shape -> Double
area (Circle r)        = pi * r * r
area (Rectangle w h)   = w * h
area (Triangle a b c)  =
  let s = (a + b + c) / 2
  in  sqrt (s * (s - a) * (s - b) * (s - c))
```

---

## 6. Pattern Matching on Custom Types

You already used pattern matching on lists and tuples in earlier lessons. The same
technique works on any data type you define.

```haskell
data TrafficLight = RedLight | YellowLight | GreenLight

action :: TrafficLight -> String
action RedLight    = "Stop"
action YellowLight = "Caution"
action GreenLight  = "Go"
```

With record types, you can pattern match by constructor and bind the fields:

```haskell
greet :: Person -> String
greet (Person { name = n, age = a }) =
  "Hello, " ++ n ++ "! You are " ++ show a ++ " years old."
```

Or more concisely with positional patterns:

```haskell
greet :: Person -> String
greet (Person n a) = "Hello, " ++ n ++ "! You are " ++ show a ++ " years old."
```

### Exhaustiveness

GHC will warn you (with `-Wall`) if your pattern match does not cover every constructor.
This is enormously valuable: if you add a new constructor to a sum type, the compiler
tells you every function that needs updating.

---

## 7. Deriving Common Type Classes

Haskell can automatically generate implementations of several standard type classes using
the `deriving` clause:

```haskell
data Priority = Low | Medium | High
  deriving (Show, Eq, Ord, Read)
```

| Type class | What it gives you                                      |
|------------|--------------------------------------------------------|
| `Show`     | Convert to `String` via `show`. Essential for printing. |
| `Read`     | Parse from `String` via `read`. Inverse of `Show`.      |
| `Eq`       | Equality comparison: `==` and `/=`.                     |
| `Ord`      | Ordering: `<`, `>`, `<=`, `>=`, `compare`. Constructors listed first are considered smaller. |

With the definition above:

```haskell
show High        -- "High"
Low == Low       -- True
Low < High       -- True   (because Low is listed before High)
read "Medium" :: Priority  -- Medium
```

### Deriving for record types

```haskell
data Point = Point { x :: Double, y :: Double }
  deriving (Show, Eq)

show (Point 1.0 2.0)  -- "Point {x = 1.0, y = 2.0}"
Point 1 2 == Point 1 2  -- True
```

Derived `Eq` compares all fields. Derived `Ord` compares fields left to right.

---

## 8. `newtype`: Lightweight Wrappers for Type Safety

Sometimes you want a new type that wraps exactly one existing type, purely for type
safety. Haskell provides `newtype` for this:

```haskell
newtype Username = Username String deriving (Show, Eq)
newtype Email    = Email    String deriving (Show, Eq)
```

Now you cannot accidentally pass a `Username` where an `Email` is expected, even though
both are "just strings" underneath.

Rules for `newtype`:

- Exactly **one** constructor.
- Exactly **one** field.
- Zero runtime overhead -- the wrapper is erased at compile time.

```haskell
newtype NoteId = NoteId Int deriving (Show, Eq, Ord)
```

Use `newtype` when you want a distinct type but not the overhead of `data`. Use `data`
when you need multiple constructors or multiple fields.

---

## 9. Type Aliases with `type`

The `type` keyword creates an alias -- a new *name* for an existing type. It does **not**
create a new type:

```haskell
type Tag      = String
type Tags     = [Tag]
type NoteList = [Note]
```

After this, `Tag` and `String` are completely interchangeable. The compiler will not stop
you from mixing them up. Use `type` only for readability; use `newtype` when you want
actual type safety.

A common example from the standard library:

```haskell
type String = [Char]   -- String is just a list of Char
```

---

## 10. Comparison to Other Languages

| Concept               | Haskell                          | Java / C#                  | TypeScript               | Rust                     |
|-----------------------|----------------------------------|----------------------------|--------------------------|--------------------------|
| Enumeration           | `data Color = Red \| Blue`       | `enum Color { RED, BLUE }` | `type Color = "red" \| "blue"` | `enum Color { Red, Blue }` |
| Struct / record       | `data P = P { x :: Int }`       | `class P { int x; }`      | `interface P { x: number }` | `struct P { x: i32 }`   |
| Tagged union          | `data Shape = Circle Double \| Rect Double Double` | Sealed classes / visitor pattern | Discriminated unions     | `enum Shape { Circle(f64), Rect(f64, f64) }` |
| Lightweight wrapper   | `newtype Id = Id Int`            | Value class / record       | Branded types (hack)     | `struct Id(i32);`        |
| Type alias            | `type Name = String`             | N/A (no true alias)        | `type Name = string`     | `type Name = String;`   |

The key advantage in Haskell: all of these are the same mechanism (`data` / `newtype` /
`type`), and pattern matching handles them all uniformly.

---

## 11. Practical Example: Modeling a Note

Here is a preview of the data types you will define in this lesson's exercise. These
same types will evolve into the core of the **hask** note manager.

```haskell
-- An enumeration (sum type with no fields)
data Priority = Low | Medium | High
  deriving (Show, Eq, Ord)

-- A record (product type with named fields)
data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Eq)

-- A combined sum + product type representing user actions
data NoteAction
  = Add Note
  | Delete Int
  | Search String
  | ListAll
  deriving (Show)
```

With these types in hand, you can write functions that are impossible to call incorrectly:

```haskell
filterByPriority :: Priority -> [Note] -> [Note]
filterByPriority p = filter (\n -> priority n == p)
```

If you accidentally pass a `String` instead of a `Priority`, the compiler catches it
immediately. This is the payoff of a strong, static type system.

---

## 12. Summary

| Keyword   | What it does                                        | When to use it                         |
|-----------|-----------------------------------------------------|----------------------------------------|
| `data`    | Defines a brand-new algebraic data type             | Most of the time                       |
| `newtype` | Defines a zero-cost wrapper around one existing type | When you want type safety for a single field |
| `type`    | Creates an alias (synonym) for an existing type     | For readability only; no type safety   |
| `deriving`| Auto-generates instances of standard type classes   | Whenever the default behavior is correct |

Key takeaways:

- **Sum types** model choices (this OR that).
- **Product types** model combinations (this AND that).
- **Pattern matching** is how you take ADTs apart.
- **deriving** saves boilerplate for Show, Eq, Ord, Read, and more.
- **newtype** gives you type safety at zero runtime cost.
- Start modeling your domain with types *first*; the functions will follow naturally.

In the exercise, you will put all of this into practice by defining the foundational data
types for the hask note manager.
