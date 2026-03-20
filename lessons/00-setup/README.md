# Lesson 00: Setup & Hello World

## What is Haskell?

Haskell is a general-purpose programming language with a few distinguishing traits:

- **Pure**: Functions have no side effects. A function called with the same arguments
  always returns the same result. Side effects (I/O, mutable state) are tracked
  explicitly in the type system.
- **Lazy**: Expressions are not evaluated until their results are actually needed.
  This enables working with infinite data structures and composing programs in
  ways that would be wasteful in strict languages.
- **Statically typed**: Every expression has a type known at compile time. The type
  system is powerful (parametric polymorphism, type classes, algebraic data types)
  and most types can be inferred automatically.
- **Compiled**: GHC (the Glasgow Haskell Compiler) produces native machine code.
  There is also an interactive REPL (GHCi) for exploration.

If you are coming from Python, TypeScript, or Java, the biggest mental shifts are:
immutability by default, functions as the primary building block, and the type system
doing much more heavy lifting than you are used to.

---

## Installing GHCup

GHCup is the recommended installer for the Haskell toolchain. It manages:

| Tool      | Purpose                                      |
|-----------|----------------------------------------------|
| **GHC**   | The Haskell compiler                         |
| **cabal** | Build tool and package manager               |
| **stack** | Alternative build tool (uses cabal under the hood) |
| **HLS**   | Haskell Language Server (editor integration) |

### Install (macOS / Linux)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Follow the prompts. The defaults are fine. When it asks about installing HLS and
Stack, say yes to both -- they are useful to have around.

After installation, open a **new** terminal (or `source ~/.ghcup/env`) and verify:

```bash
ghc --version        # e.g. The Glorious Glasgow Haskell Compilation System, version 9.6.x
cabal --version      # e.g. cabal-install version 3.10.x
ghci --version       # same as ghc
```

### Install (Windows)

Download the GHCup installer from <https://www.haskell.org/ghcup/> and run it.
The rest of this course assumes a Unix-like shell, but all commands work in
PowerShell or WSL with minor adjustments.

### Updating later

```bash
ghcup tui            # interactive terminal UI to install/switch versions
ghcup upgrade        # upgrade ghcup itself
ghcup install ghc 9.8.1   # install a specific GHC version
ghcup set ghc 9.8.1       # make it the default
```

---

## Using GHCi (the REPL)

Start it:

```bash
ghci
```

You will see a prompt like `ghci>` or `Prelude>`. Try some expressions:

```haskell
ghci> 2 + 3
5

ghci> "hello" ++ " " ++ "world"
"hello world"

ghci> length [1, 2, 3, 4]
4

ghci> map (*2) [1..5]
[2,4,6,8,10]

ghci> head [10, 20, 30]
10
```

### Useful GHCi commands

| Command       | What it does                                |
|---------------|---------------------------------------------|
| `:type expr`  | Show the type of an expression (`:t` for short) |
| `:info name`  | Show info about a type, class, or function  |
| `:load File.hs` | Load a Haskell source file (`:l` for short) |
| `:reload`     | Reload the current file (`:r`)              |
| `:quit`       | Exit GHCi (`:q`)                            |

### Exploring types

Types are central to Haskell. Get in the habit of checking them:

```haskell
ghci> :type True
True :: Bool

ghci> :type "hello"
"hello" :: String

ghci> :type not
not :: Bool -> Bool

ghci> :type putStrLn
putStrLn :: String -> IO ()
```

Read `String -> IO ()` as: "a function that takes a `String` and returns an I/O
action producing nothing (`()`, the unit type)."

### Multiline input

Use `:{` and `:}` for multiline expressions:

```haskell
ghci> :{
ghci| let greet name =
ghci|       "Hello, " ++ name ++ "!"
ghci| :}

ghci> greet "Alice"
"Hello, Alice!"
```

---

## Your first program

Create a file called `Main.hs`:

```haskell
module Main where

main :: IO ()
main = putStrLn "Hello, World!"
```

Let's break this down:

### `module Main where`

Every Haskell source file is a module. The compiler expects the entry point of an
executable to be in a module called `Main`, containing a value called `main`.

### `main :: IO ()`

This is a **type signature**. It says: `main` has type `IO ()`.

- `IO` is a type that represents an I/O action -- something that can interact with
  the outside world (print to screen, read files, etc.).
- `()` (unit) means the action does not produce a meaningful return value.
- Haskell separates pure computation from I/O at the type level. A function with
  type `Int -> Int` cannot print to the screen. If it needs to do I/O, its return
  type must involve `IO`.

### `putStrLn`

```haskell
putStrLn :: String -> IO ()
```

Takes a `String`, prints it to stdout followed by a newline. This is the Haskell
equivalent of `print()` / `console.log()` / `System.out.println()`.

There is also `print`, which works on any type that implements `Show`:

```haskell
ghci> print 42
42
ghci> print [1,2,3]
[1,2,3]
ghci> putStrLn "hello"
hello
```

Note: `print "hello"` outputs `"hello"` (with quotes), because it shows the Haskell
representation. Use `putStrLn` when you want plain text output.

---

## Reading command-line arguments

The module `System.Environment` provides `getArgs`:

```haskell
getArgs :: IO [String]
```

It returns an I/O action that produces a list of strings -- the command-line
arguments passed to the program (excluding the program name).

Here is a program that uses it:

```haskell
module Main where

import System.Environment (getArgs)

main :: IO ()
main = do
    args <- getArgs
    case args of
        (name:_) -> putStrLn ("Hello, " ++ name ++ "!")
        []       -> putStrLn "Hello, World!"
```

### New concepts

**`import System.Environment (getArgs)`** -- Import only `getArgs` from the module.
You could also write `import System.Environment` to import everything.

**`do` notation** -- Lets you sequence I/O actions. Each line in a `do` block is
either:
- An action: `putStrLn "hi"` (execute it, discard result)
- A binding: `args <- getArgs` (execute the action, bind the result to `args`)

Think of `do` blocks as Haskell's way of writing imperative-looking code while
keeping the type system honest about side effects.

**`args <- getArgs`** -- The `<-` operator "unwraps" the `IO [String]` to get the
`[String]` inside. The variable `args` now has type `[String]`.

**`case ... of`** -- Pattern matching. This is how Haskell does conditional logic
on data structures:

```haskell
case args of
    (name:_) -> ...   -- args is non-empty; bind first element to 'name', ignore rest
    []       -> ...   -- args is empty
```

The pattern `(name:_)` destructures a list: `name` is the head (first element),
`_` is the tail (which we don't care about, so we use underscore).

**String concatenation** -- The `++` operator concatenates lists. Since `String` is
just `[Char]` (a list of characters) in Haskell, `++` is also string concatenation.

---

## Compiling and running

### Compile

```bash
ghc -o hello Main.hs
```

This produces:
- `hello` -- the executable
- `Main.hi` -- interface file (module metadata)
- `Main.o` -- object file

### Run

```bash
./hello
# Hello, World!

./hello Alice
# Hello, Alice!
```

### Cleaning up build artifacts

The `.hi` and `.o` files are intermediate build artifacts. You can safely delete
them:

```bash
rm -f *.hi *.o
```

For larger projects you would use `cabal` or `stack` which manage build artifacts
in a dedicated directory, but for single-file programs, `ghc` directly is fine.

### Running without compiling

You can also run a Haskell file directly with `runghc` (interpreted, slower, but
convenient for scripting):

```bash
runghc Main.hs
runghc Main.hs Alice
```

Or load it in GHCi:

```bash
ghci Main.hs
ghci> main            -- runs main with no args
ghci> :main Alice     -- runs main with args
```

---

## Quick reference

| Task                      | Command / Code                          |
|---------------------------|-----------------------------------------|
| Start REPL                | `ghci`                                  |
| Check type                | `:type expr` or `:t expr`               |
| Load file in REPL         | `:load Main.hs` or `:l Main.hs`        |
| Compile                   | `ghc -o program Main.hs`               |
| Run interpreted           | `runghc Main.hs`                        |
| Print a string            | `putStrLn "text"`                       |
| Print any showable value  | `print value`                           |
| Get CLI args              | `getArgs` (from `System.Environment`)   |
| String concatenation      | `"a" ++ "b"`                            |
| Pattern match on list     | `case xs of { (x:rest) -> ...; [] -> ... }` |

---

## Key takeaways

1. **GHCup** installs and manages the entire Haskell toolchain.
2. **GHCi** is your scratchpad -- use it constantly to test expressions and check types.
3. Every executable needs `module Main where` and `main :: IO ()`.
4. Side effects live in `IO`. Pure functions cannot do I/O.
5. `do` notation sequences I/O actions. `<-` binds results.
6. Pattern matching with `case` is how you branch on data.
7. `ghc -o name Main.hs` compiles to a native binary.

You now have a working Haskell installation and your first compiled program. In the
next lesson we will dive into the type system.
