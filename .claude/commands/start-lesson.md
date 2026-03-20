Start a lesson for the Haskell course.

Argument: $ARGUMENTS (optional lesson number)

Steps:
1. Read progress.json from the project root
2. Determine which lesson to start:
   - If an argument is provided, use that lesson number
   - Otherwise use the `current_lesson` field from progress.json
3. Map the lesson number to its directory:
   - 0 -> lessons/00-setup/
   - 1 -> lessons/01-types-and-functions/
   - 2 -> lessons/02-lists-and-pattern-matching/
   - 3 -> lessons/03-recursion-hof/
   - 4 -> lessons/04-adt/
   - 5 -> lessons/05-typeclasses/
   - 6 -> lessons/06-modules-and-project/
   - 7 -> lessons/07-io-and-files/
   - 8 -> lessons/08-error-handling/
   - 9 -> lessons/09-libraries/
   - 10 -> lessons/10-monads-and-transformers/
   - 11 -> lessons/11-testing/
   - 12 -> lessons/12-polish/
4. Check that the lesson directory exists. If not, tell the student.
5. If the lesson is already completed, mention that and ask if they want to redo it.
6. Read and display the lesson's README.md (the teaching material). Present it in full -- this is the lecture.
7. Read and display the lesson's exercise.md (what to build). Present it clearly.
8. If a scaffold/ directory exists in the lesson, copy its contents to the appropriate working location.
9. Update progress.json: set the lesson's status to "in_progress".
10. Encourage the student to start working, and remind them they can use /hint if stuck and /end-lesson when done.
