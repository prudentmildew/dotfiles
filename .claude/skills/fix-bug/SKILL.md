---
name: fix-bug
description: Use the triage-bug skill to fix a bug from a GitHub issue. Use when user wants to fix a bug reported as a GitHub issue or when they mention "fix bug" or "fix (github) issue".
---

# Fix Bug

Use the /triage-bug skill to fix a bug from a GitHub issue.

## Process:
1. Read bug description from github issue [ask the user for issue id]
2. Invoke `/triage-bug` on the GitHub issue to fix it. Read title, description and comments.
3. When we have a plan, append it to the issue description, under a new section: "Proposed fix".
4. Create a new branch (if not alreadye created): bug/[issue-id]-[sanitized-issue-title] and add all and any commits there.
5. Add progress summaries as comments to the issue.
6. When a fix has been implemented, create a PR labeled "bug-fix" (only if not already created), that closes the bug issue.
7. Do not close or merge the PR!