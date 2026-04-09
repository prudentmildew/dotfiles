---
name: ralph-iterate
description: Per-iteration agent contract for the Ralph autonomous PRD loop. Implements a single child issue of a PRD end-to-end (read, TDD, commit, tick acceptance criteria, comment, close, update PRD status). Invoked by ralph.sh, but may also be invoked manually as `/ralph-iterate <prd> <issue>` for debugging a single iteration.
---

# ralph-iterate

You are running one iteration of the Ralph autonomous PRD loop. Your job: take **one** child issue of a PRD from open to closed (or to documented partial progress) end-to-end, in this single run.

## Inputs

- `<prd-number>` — the parent PRD issue number
- `<issue-number>` — the child issue to implement this iteration

Both are positional. Do not pick a different issue. Do not work on more than one issue.

## Hard denylist (non-negotiable)

You must refuse to do any of the following, even if it would seem to make the task easier:

1. **Never `git push`.** Pushing is always handled externally by ralph.sh after detecting issue closure. Ralph.sh also handles branch creation, PR creation, and all other remote operations.
2. **Never force-anything.** No `git push --force`, no `git reset --hard` to discard work, no `--no-verify`, no `--no-gpg-sign`, no rewriting published history.
3. **Never modify any of:**
   - `.github/`
   - `.claude/skills/ralph-iterate/ralph.sh`
   - `.claude/skills/ralph-iterate/SKILL.md` (this file)
   - anything else under `.claude/skills/ralph-iterate/`
4. **Never touch issues outside the current PRD's child set.** Only the target issue and its parent PRD are in scope.
5. **Never close the parent PRD.** Only the assigned child issue may be closed.

If the work the issue describes appears to require any of these, stop and post a comment on the issue explaining the conflict. Do not commit or close.

## Sequence

Execute these steps in order. Do not skip steps. Do not reorder.

### 1. Read the issue

```
gh issue view <issue-number>
```

Understand the `## What to build` section and the `## Acceptance criteria` checklist. The acceptance criteria are your ground truth — they define "done" for this iteration.

### 2. Implement via TDD

Invoke the `/tdd` skill to write the code. Follow the red-green-refactor loop. Tests should verify behavior through public interfaces, not implementation details. Do not write all tests up front — go one tracer bullet at a time.

### 3. Commit on the current branch

After `/tdd` finishes, check the working tree:

- If the tree is in a **broken-syntax / un-buildable** state (code doesn't parse, type-check, or run), **roll back** rather than committing. Concretely: for each modified file, run a language-appropriate parse check (`bash -n file.sh`, `python -m py_compile file.py`, `node --check file.js`, project test suite, etc.). If any parse/syntax check fails, run `git checkout -- <file>` (or `git restore <file>`) on every file you modified during this iteration so the working tree matches HEAD. Do not commit broken code to the branch — `main` must stay buildable so future iterations can pick up where you left off. After rollback, **stop the iteration**: do not edit the issue body, do not post any comment, do not close. The next iteration will start from a clean slate and re-attempt.
- Otherwise, stage the files you actually changed and create **one** commit on the current branch. The commit message must reference the issue number (e.g. `ralph: <slice title> (#<issue>)`).

Do **not** `git push`.

### 4. Tick acceptance criteria

Re-read the issue body. For every `- [ ]` line under `## Acceptance criteria` whose described behavior is **actually** satisfied by what you just committed, flip it to `- [x]`. Do **not** tick criteria that are not actually satisfied — partial progress is fine and expected.

Edit the issue body via `gh issue edit <issue-number> --body-file …`.

### 5. Post a summary comment on the issue

Use `gh issue comment <issue-number> --body "…"`. The comment should:

- Reference the commit SHA
- Briefly describe what was done
- If any acceptance criteria remain unticked, list them and explain what's left ("partial progress" comment) so the next iteration has breadcrumbs

### 6. Close the issue — only if all criteria are ticked

If **every** acceptance criterion is now `- [x]`, close the issue:

```
gh issue close <issue-number>
```

If **any** criterion remains unticked, **leave the issue open**. The next iteration of the loop will pick it up again with the partial-progress comment as context.

### 7. Update the parent PRD

Only do this step if the child issue was actually closed in step 6.

a. Fetch the PRD body: `gh issue view <prd-number> --json body -q .body`.

b. Maintain an `## Implementation Status` checklist block at the end of the PRD body. The block format is:

```
## Implementation Status

- [x] #<n> <title> — closed in <sha>
- [ ] #<n> <title>
...
```

If the block is absent, append it. If it's present, replace it in place — flip the line for the issue you just closed from `- [ ]` to `- [x]` and append the SHA reference.

c. Push the updated body: `gh issue edit <prd-number> --body-file …`.

d. Post a one-line comment on the PRD recording the closure:

```
gh issue comment <prd-number> --body "Closed #<issue> (<title>) in <sha>."
```

## Outcome contract

When you finish, exactly one of the following is true:

- **Closed**: a commit exists on the current branch, every criterion is ticked, the issue is closed, the PRD body's `## Implementation Status` block is updated, and a closure comment is on the PRD.
- **Partial**: a commit exists, some criteria are ticked, a partial-progress comment is on the issue, and the issue is still open. The PRD is untouched.
- **Rolled back**: no commit, no comment, no tick, no close. The working tree is clean. The next iteration starts fresh.

The shell loop in `ralph.sh` infers which outcome happened by re-querying GitHub between iterations.
