# Ralph Sandbox Runner

**Date:** 2026-04-17

**Status:** Ideation complete

## Overview

A shell script (`ralph.sh`) that autonomously implements vertical-slice GitHub issues from a PRD by running Claude inside a Docker sandbox (`sbx`). The script handles all deterministic work (git, GitHub, branch management, testing) and only delegates implementation to Claude.

## Usage

```bash
ralph.sh <iterations> <issue>
```

- `iterations` — max number of loop iterations
- `issue` — GitHub issue number or full URL pointing to the PRD

**Example:**
```bash
ralph.sh 5 123
ralph.sh 10 https://github.com/owner/repo/issues/123
```

## File location

`~/.dotfiles/.local/bin/ralph.sh` (already on PATH)

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Iteration control | Script-level loop (not in-session Ralph plugin) | Simpler, observable, shell-level Ctrl+C |
| Per-iteration model | Fresh `sbx run claude . -- -p "..."` each time | Stateless from sbx perspective; project files carry state |
| Prompt source | Script constructs it from issue data | Script discovers the next slice; Claude only implements |
| Skill referenced | `/tdd` | Single red-green-refactor pass per slice; no implicit inner loop |
| Branch strategy | Fresh from `main` each iteration | Clean branches, no cross-slice conflicts |
| PR management | Script opens PRs (not Claude) | Deterministic; only opens if tests pass |
| Issue closing | `Closes #N` in PR body | GitHub handles closure on merge; keeps user in control |
| Config sync | `rsync -au` | Idempotent; only copies newer/changed files |
| Test detection | Auto-detect from project files | No extra args needed |
| Early exit | Script checks via `gh` before each iteration | Stops when no eligible slices remain |

## Flow

### 1. Validate and setup

- Parse `<iterations>` and `<issue>` args
- Auto-detect repo: `gh repo view --json nameWithOwner -q .nameWithOwner`
- Extract issue number from URL if full URL provided

### 2. Sync Claude config (idempotent)

Copy from `~/.claude/` into project `.claude/` using `rsync -au`:
- `~/.claude/skills/` -> `.claude/skills/`
- `~/.claude/settings.json` -> `.claude/settings.json`
- `~/.claude/statusline-command.sh` -> `.claude/statusline-command.sh`

All three are gitignored in the target project.

### 3. Loop (up to N iterations)

```
for i in 1..iterations:
    a. git checkout main && git pull origin main

    b. Query GitHub for eligible slices:
       - List sub-issues of PRD issue (from task list)
       - Filter out issues that already have an open PR
       - If none remain → exit early with success

    c. Select next eligible slice (first open one without a PR)

    d. Create branch:
       - Delete old local branch `issue-<N>-<slug>` if exists
       - git checkout -b issue-<N>-<slug> main

    e. Launch Claude in sandbox:
       sbx run claude . -- -p "Implement GitHub issue #<N>: <title>. Use /tdd. Commit when done."

    f. Auto-detect and run tests:
       - Makefile         → make test
       - package.json     → npm test
       - build.gradle     → ./gradlew test
       - (others as needed)
       - If no test runner detected → warn, skip gate

    g. If tests pass:
       - git push -u origin issue-<N>-<slug>
       - gh pr create --title "<title>" --body "Closes #<N>"
       → continue to next iteration

    h. If tests fail:
       - Log warning with iteration number and issue
       - Leave branch as-is (for inspection)
       → continue to next iteration
       (same slice will be retried since no PR was opened)
```

### 4. Done

Print summary:
- Total iterations run
- PRs opened (with URLs)
- Failed iterations (with issue numbers)

## Key Principles

- **Script does all deterministic work** — git operations, GitHub queries, branch management, test running, PR creation. Claude only does implementation.
- **Token-efficient** — Claude receives a focused prompt with just the issue number, title, and instruction to use `/tdd`.
- **Idempotent config sync** — `rsync -au` only copies when source is newer.
- **Natural retry** — failed slices (tests don't pass) are automatically retried on the next iteration since no PR was opened.
- **User stays in control** — PRs are the review gate; issues close only when PRs are merged.
