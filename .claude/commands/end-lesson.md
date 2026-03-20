Grade and complete the current lesson.

Steps:
1. Read progress.json to find which lesson is currently "in_progress".
   - If no lesson is in_progress, tell the student to start a lesson first with /start-lesson.
2. Map the lesson number to its directory (same mapping as start-lesson).
3. Read the lesson's grading.json file.
4. Execute each check in the grading.json "checks" array. For each check:

   **file_exists**: Check if the file at the given path exists (relative to project root).

   **file_contains**: Read the file and check if the content matches the regex pattern.

   **compile**: Run the compile command from the project root directory. Expect exit code 0.

   **run**: Run the command from the project root directory. Check that stdout contains the expected_output string.

   **run_sequence**: Run each step's command in order from the project root. For each step, check stdout contains expected_output.

   **cabal_test**: Run `cabal test` in the specified directory. Expect exit code 0.

5. Report results for each check:
   - Show a pass/fail indicator for each check with its description
   - If a check fails, explain what went wrong and give guidance on how to fix it

6. If ALL checks pass:
   - Update progress.json: set the lesson status to "completed" with a "completed_at" date
   - Advance current_lesson to the next lesson number
   - Congratulate the student and suggest running /start-lesson for the next lesson

7. If ANY checks fail:
   - Do not update progress.json
   - Encourage the student to fix the issues and try again
   - Remind them they can use /hint if stuck
