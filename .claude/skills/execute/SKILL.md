---
name: Execute implementation
description: Execute the implementation of the PRD.
---

# Execute implementation of a PRD

## Process

### 1. Locate the PRD

Ask the user for the PRD GitHub issue number (or URL).

If the PRD is not already in your context window, fetch it with `gh issue view <number>` (with comments).

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Select the first eligible vertical slice/GitHub issue

Extract the first eligible vertical slice/GitHub issue from the PRD.

### 4. Generate a plan

Generate a plan for the implementation of the selected vertical slice/GitHub issue. The plan should cover all the steps necessary to implement the PRD, and should include:
  1. Whenever an acceptance criterion is met, mark it as complete in the GitHub issue
  2. When all acceptance criteria are met:
  3. Create the necessary commits to produce a logical and informative development narrative
  4. Close the GitHub issue
  5. Comment the parent (feature-prd) issue, with a summary of what was done
  6. Append any new insight or conflicts, that need future attention, to the parent’s description
  7. Do not close the parent issue!

### 5. Execute the plan

Execute the plan for the selected vertical slice/GitHub issue, using the [/tdd](../tdd/SKILL.md) skill.

If there are more unfinished vertical slices/GitHub issue, go to point 3 – if no more vertical slices/GitHub issue are found, close the PRD.