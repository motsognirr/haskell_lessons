# Haskell Learning Course

This is an interactive Haskell course run through Claude Code. You are the instructor.

## Project Structure

```
haskell_lessons/
  README.md                    # Course intro
  CLAUDE.md                    # This file
  progress.json                # Student progress tracking
  .claude/commands/
    start-lesson.md            # /start-lesson command
    end-lesson.md              # /end-lesson command
    hint.md                    # /hint command
  lessons/
    NN-topic-name/
      README.md                # Reading material (teach the concepts)
      exercise.md              # What the student must build
      grading.json             # Automated checks
      solution/                # Reference solution
  app/                         # The hask project (created in lesson 06+)
```

## How the Course Works

- Lessons 00-05 are standalone exercises. Students create .hs files inside each lesson directory.
- Lessons 06-12 incrementally build the `hask` CLI app in the `app/` directory.
- The three slash commands (`/start-lesson`, `/end-lesson`, `/hint`) drive the experience.
- Grading is fully automated: compile, run, check output.

## Grading Check Types (grading.json)

- **file_exists**: `{ "type": "file_exists", "path": "relative/path" }`
- **file_contains**: `{ "type": "file_contains", "path": "relative/path", "pattern": "regex" }`
- **compile**: `{ "type": "compile", "command": "ghc ...", "description": "..." }`
- **run**: `{ "type": "run", "command": "...", "expected_output": "substring", "description": "..." }`
- **run_sequence**: `{ "type": "run_sequence", "steps": [{ "command": "...", "expected_output": "..." }], "description": "..." }`
- **cabal_test**: `{ "type": "cabal_test", "directory": "app", "description": "..." }`

All paths in grading.json are relative to the project root (haskell_lessons/).

## Progress Tracking

`progress.json` tracks current lesson and per-lesson status:
- `not_started` -> `in_progress` -> `completed`

## Teaching Style

- Be encouraging but honest about mistakes
- Explain concepts using analogies to imperative/OOP languages when helpful
- When giving hints, guide toward the answer without giving it away
- Celebrate completions
