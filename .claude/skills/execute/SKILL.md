---
name: Execute implementation
description: Execute the implementation of the PRD by breaking it down into vertical slices and implementing them one by one using TDD.
---

# Execute implementation of a PRD

Implement a PRD by processing its `vertical-slice` GitHub issues one by one.

## Process

### 1. Locate the PRD

Ask the user for the PRD GitHub issue number (or URL).
Fetch the PRD with `gh issue view <number> --comments` to get full context.

### 2. Ensure Task Breakdown

Check if the PRD has associated `vertical-slice` issues.
If the PRD is not yet broken down into issues, recommend using the [/kanban](../kanban/SKILL.md) skill first to create a roadmap of vertical slices.

### 3. Explore the Codebase (Optional)

If you have not already explored the codebase, use the [/explore-codebase](../explore-codebase/SKILL.md) skill or manually explore to understand the current state of the code.

### 4. Select the Next Vertical Slice

List all open `vertical-slice` issues related to the PRD:
`gh issue list --label vertical-slice --search "PRD #<prd-number>"` (or similar search).

Pick the first eligible slice:
- Not blocked by other open issues.
- Not currently in progress.
- Matches the user's priority.

Confirm the selection with the user.

### 5. Implementation Loop

For the selected `vertical-slice` issue:

#### A. Prepare the Environment
1. Create a new feature branch: `git checkout -b feature/<issue-number>-<short-description>`.
2. Ensure the base branch (e.g., `main`) is up to date and merged into your feature branch if needed.

#### B. Generate Implementation Plan
Create a plan for the specific slice, including:
- Identifying relevant files and modules.
- Listing the Acceptance Criteria (AC) from the issue.
- Designing the public interfaces to be modified or created.
- Mapping out the TDD cycles (RED -> GREEN -> REFACTOR) for each AC.
- Mentioning how to mark ACs as complete in the GitHub issue.

#### C. Execute via TDD
Use the [/tdd](../tdd/SKILL.md) skill to implement the slice.
- For each AC, write a failing test first.
- Implement the minimal code to pass the test.
- Refactor and ensure all tests pass.
- Mark the AC as complete in the GitHub issue using `gh issue edit <number> --body "..."` (updating the checkboxes).

#### D. Finalize the Slice
1. Run all relevant tests (both new and existing) to ensure no regressions.
2. Create logical, informative commits that tell a development story.
3. Push the branch to the remote: `git push -u origin <branch-name>`.
4. Optionally create a Pull Request: `gh pr create --fill --label vertical-slice`.
5. Close the `vertical-slice` issue: `gh issue close <number> --comment "Implemented in PR #<pr-number> (or branch <branch-name>)"`.
6. Comment on the parent PRD issue with a summary of what was done and a reference to the branch/PR.
7. Append any new insights, technical debt, or conflicts to the parent PRD's description if they need future attention.

### 6. Loop or Close PRD

If more `vertical-slice` issues remain, go back to **Step 4**.

If all slices are completed:
1. Verify the overall implementation against the original PRD's goals.
2. Ask the user if they want to close the PRD issue.
3. If confirmed, close the PRD issue with a final summary of the feature's implementation.
4. Do NOT close the PRD issue if there are still open questions or follow-up tasks.