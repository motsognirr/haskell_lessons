# Exercise 00: Setup & Hello World

## Objective

Install the Haskell toolchain, write a small program that reads command-line
arguments, and compile it with GHC.

---

## Part 1: Install GHCup

1. Install GHCup by following the instructions at <https://www.haskell.org/ghcup/>.

2. Verify your installation by running these commands (exact versions may differ):

   ```bash
   ghc --version
   ghci --version
   ```

   Both should print a version number without errors.

3. Open `ghci`, type `2 + 3`, confirm you see `5`, then type `:quit` to exit.

---

## Part 2: Write the program

Create the file `lessons/00-setup/Main.hs` with the following requirements:

### Requirements

- The module must be named `Main`.
- You must import `getArgs` from `System.Environment`.
- The program must read command-line arguments using `getArgs`.
- **If one or more arguments are provided**, print:
  ```
  Hello, {name}! Welcome to Haskell.
  ```
  where `{name}` is the **first** argument. Ignore any additional arguments.
- **If no arguments are provided**, print:
  ```
  Hello, World! Welcome to Haskell.
  ```
- Output must go to stdout and end with a newline (use `putStrLn`).
- The output must match **exactly** -- pay attention to punctuation and spacing.

### Constraints

- Do not use any external packages. Only modules from `base` are allowed.
- Do not prompt for user input (no `getLine`, no `stdin` reading).
- The program must compile without warnings using `ghc`.

---

## Part 3: Compile and test

Compile your program:

```bash
cd lessons/00-setup
ghc -o hello Main.hs
```

This should complete without errors.

Test it:

```bash
./hello
# Expected output: Hello, World! Welcome to Haskell.

./hello Alice
# Expected output: Hello, Alice! Welcome to Haskell.

./hello Bob extra args
# Expected output: Hello, Bob! Welcome to Haskell.
```

---

## Grading criteria

Your submission will be checked automatically:

| Check                          | What is verified                                        |
|--------------------------------|---------------------------------------------------------|
| File exists                    | `lessons/00-setup/Main.hs` is present                  |
| Imports System.Environment     | Source contains `import System.Environment`              |
| Compiles                       | `ghc -o hello Main.hs` exits with code 0               |
| No-args output                 | `./hello` prints `Hello, World! Welcome to Haskell.`   |
| Named greeting                 | `./hello Alice` prints `Hello, Alice! Welcome to Haskell.` |

---

## Hints

- Look at the `case ... of` syntax from the README for pattern matching on lists.
- `getArgs` returns `IO [String]` -- use `<-` in a `do` block to get the `[String]`.
- The pattern `(x:_)` matches a non-empty list and binds the first element to `x`.
- String concatenation in Haskell uses `++`.
- If you get stuck, try building up the program step by step in `ghci` using `:load`.
