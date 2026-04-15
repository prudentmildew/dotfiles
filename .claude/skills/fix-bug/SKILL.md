---
name: fix-bug
description: Fix a bug from an existing GitHub issue using TDD. Investigate the root cause, create a TDD plan, and execute it by following a red-green-refactor loop. Use when a user provides a GitHub issue ID/URL or asks to fix a bug.
---

# Fix Bug

This skill guides you through fixing a bug reported on GitHub by triaging, planning, and executing a TDD-based fix.

## Process

### 1. Get Context & Pre-checks
- **Identify Issue**: If the user hasn't provided an issue ID or URL, ask for one.
- **Environment**: Check if the working directory is clean. If there are uncommitted changes, ask the user to stash or commit them before proceeding.
- **Fetch Details**: Use `gh issue view <id>` to read the title, description, and comments.
- **Status Check**: If the issue is already closed, inform the user and ask for confirmation to proceed.

### 2. Triage & Planning
- **Analyze**: Check if the issue contains a **TDD Fix Plan** (a numbered list of RED-GREEN cycles).
- **Investigate**: If no plan exists (or it's insufficient), use the "Explore and diagnose" logic from `/triage-bug` to find the root cause.
- **Update Issue**: Add a "Proposed Fix" section to the issue (using `gh issue edit` or `gh issue comment`) including:
  - **Root Cause Analysis**: Why it fails and the code path involved.
  - **TDD Fix Plan**: A list of vertical slices (RED test → GREEN implementation).
- **Confirmation**: Present the plan to the user and get approval before writing any code.

### 3. Branching
- Create a new branch: `bug/<issue-id>-<sanitized-title>`.
- **Sanitization**: Lowercase, replace non-alphanumeric characters with dashes, and limit to 50 characters.
- **Existing Branch**: If the branch already exists, ask the user whether to reuse it, overwrite it, or use a different name.

### 4. Implementation (TDD Loop)
Follow the plan using vertical slices (refer to `/tdd` skill):
- For each cycle:
  1. **RED**: Write a test that reproduces the bug. Verify it fails.
  2. **GREEN**: Write the minimal code to pass the test.
  3. **Commit**: `git commit -m "fix: <step description> (#<issue-id>)"`.
- **Progress Updates**: After each cycle, add a comment to the GitHub issue with a brief summary of progress.

### 5. Validation & Pull Request
- **Regression Testing**: Run ALL relevant tests in the project to ensure no new bugs were introduced.
- **Create PR**: Use `gh pr create --label "bug-fix"`.
  - **Title**: `fix: <issue-title> (#<issue-id>)`
  - **Body**: Include "Fixes #<issue-id>" and a summary of the changes.
- **Important**: Do NOT merge or close the PR yourself.
- **Final Report**: Share the PR URL and a summary of the work with the user.

## Edge Cases

- **Reproduction failure**: If you cannot reproduce the bug, document your investigation steps in the issue and ask the user for more information or a reproduction script.
- **CLI missing**: If `gh` is not installed or authenticated, provide the user with the command to set it up.
- **Complex Fixes**: If the fix requires a major architectural change, stop and discuss with the user before proceeding.
- **Merge Conflicts**: If you encounter conflicts while branching or pushing, resolve them or ask the user for guidance.