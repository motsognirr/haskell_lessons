Provide a hint for the current lesson exercise.

Steps:
1. Read progress.json to find which lesson is currently "in_progress".
   - If no lesson is in_progress, tell the student to start a lesson first with /start-lesson.
2. Map the lesson number to its directory (same mapping as start-lesson).
3. Read the lesson's exercise.md to understand what's being asked.
4. Read the lesson's grading.json to understand the specific requirements and checks.
5. Find and read the student's current code files:
   - For lessons 00-05: look for .hs files in the lesson directory
   - For lessons 06-12: look for relevant files in the app/ directory
6. Analyze the gap between the student's current code and what the grading checks expect.
7. Provide a CONCEPTUAL hint that guides the student toward the solution WITHOUT giving the answer:
   - Point out which concept they should focus on
   - If they have a specific error, explain what it means
   - Suggest what to look up or re-read from the lesson material
   - If they're completely stuck, give a slightly more direct nudge
   - NEVER show the complete solution or copy from the solution/ directory
8. Keep hints progressive -- if the student asks for multiple hints, get progressively more specific.
