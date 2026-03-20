# Exercise 01: Types & Functions

## Goal

Create a file called `Main.hs` in this directory
(`lessons/01-types-and-functions/Main.hs`) and implement the functions described
below. The file should compile with `ghc` and produce the expected output when
run.

---

## Setup

Your file should start with:

```haskell
module Main where
```

---

## Functions to Implement

### 1. `celsiusToFahrenheit`

```haskell
celsiusToFahrenheit :: Double -> Double
```

Converts a temperature from Celsius to Fahrenheit.

**Formula:** `c * 9 / 5 + 32`

**Example:**
```
ghci> celsiusToFahrenheit 100
212.0
ghci> celsiusToFahrenheit 0
32.0
```

### 2. `fahrenheitToCelsius`

```haskell
fahrenheitToCelsius :: Double -> Double
```

Converts a temperature from Fahrenheit to Celsius.

**Formula:** `(f - 32) * 5 / 9`

**Example:**
```
ghci> fahrenheitToCelsius 212
100.0
ghci> fahrenheitToCelsius 32
0.0
```

### 3. `greet`

```haskell
greet :: String -> String -> String
```

Takes a first name and a last name and returns a greeting string.

**Example:**
```
ghci> greet "John" "Doe"
"Hello, John Doe!"
```

### 4. `initials`

```haskell
initials :: String -> String -> String
```

Takes a first name and a last name and returns the initials, each followed by a
dot.

**Hint:** Use `head` to get the first character of a string. Remember that a
`Char` can be prepended to a `String` using the `:` operator.

**Example:**
```
ghci> initials "John" "Doe"
"J.D."
ghci> initials "Ada" "Lovelace"
"A.L."
```

---

## The `main` Function

Your `main` function should demonstrate all four functions with specific test
values. Use `print` for numeric results and `putStrLn` for string results.

```haskell
main :: IO ()
main = do
  print (celsiusToFahrenheit 100)
  print (fahrenheitToCelsius 32)
  putStrLn (greet "John" "Doe")
  putStrLn (initials "John" "Doe")
```

---

## Expected Output

When you compile and run your program, the output should be exactly:

```
212.0
0.0
Hello, John Doe!
J.D.
```

---

## How to Compile and Run

```bash
cd lessons/01-types-and-functions
ghc -o types Main.hs
./types
```

---

## Hints

- Remember: no parentheses around function arguments, no commas between them.
- String concatenation uses `++`.
- `head "John"` gives you `'J'` (a `Char`).
- To turn a `Char` into a one-character `String`, you can use `[c]` or `c : ""`.
- The `:` operator prepends a `Char` to a `String`: `'J' : ".D."` gives `"J.D."`.
- All functions should have explicit type signatures.

---

## Checking Your Work

Your solution passes when:

1. The file exists at `lessons/01-types-and-functions/Main.hs`
2. It contains type signatures for `celsiusToFahrenheit` and `fahrenheitToCelsius`
3. It compiles without errors: `ghc -o types Main.hs`
4. Running `./types` produces the exact output shown above
