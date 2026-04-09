# ralph-iterate

Autonomous PRD implementation loop for Claude Code. Ralph takes a GitHub issue-based PRD (Product Requirements Document) and implements its child issues one at a time using TDD, committing progress and updating GitHub as it goes.

## Architecture

```
ralph.sh              Shell loop controller — picks eligible issues, invokes Claude, detects outcomes
  ├── eligibility.sh  Determines which child issues are eligible (open, unblocked)
  ├── docker_cmd.sh   Builds the Claude execution command (plain or Docker sandbox)
  ├── branch_mgr.sh   Per-issue branch lifecycle (create, reuse, cleanup)
  ├── pr_creator.sh   Automatic PR creation after issue closure
  ├── reporter.sh     Structured terminal output (banners, outcome lines, summary table)
  └── SKILL.md        Agent contract — defines the per-iteration behavior for Claude
```

## Usage

```bash
# Run the full loop against PRD #42
./ralph.sh 42

# Preview which issue would be picked next
./ralph.sh 42 --dry-run

# Run in an isolated git worktree
./ralph.sh 42 --worktree

# Run Claude inside a Docker container for process isolation
./ralph.sh 42 --docker

# Combine Docker isolation with git worktree isolation
./ralph.sh 42 --docker --worktree

# Override the Docker command (custom image, flags, etc.)
RALPH_CLAUDE_CMD="docker sandbox run my-claude-image" ./ralph.sh 42 --docker

# Preview the Docker command without executing
./ralph.sh 42 --docker --dry-run

# Limit to 10 iterations
./ralph.sh 42 --max-iterations 10

# Manually invoke a single iteration (useful for debugging)
# via Claude Code slash command:
/ralph-iterate 42 15
```

## How it works

1. **ralph.sh** queries GitHub for open child issues of the given PRD
2. **eligibility.sh** filters to issues that are unblocked (all `## Blocked by` references are closed)
3. The lowest-numbered eligible issue is passed to Claude via `/ralph-iterate <prd> <issue>`
4. Claude reads the issue, implements it via TDD, commits, ticks acceptance criteria, and closes the issue if complete
5. The loop repeats until all children are closed or a stop condition is hit

## Docker sandbox mode

When `--docker` is passed, Claude runs inside a Docker container via `docker sandbox run claude` instead of directly on the host. This provides process isolation without changing any other behavior.

Bind mounts:
- **Repo directory** — read-write (so Claude can modify code)
- **`~/.gitconfig`** — read-only (git identity available inside container)
- **`~/.config/gh/`** — read-only (GitHub CLI credentials)
- **`~/.claude/`** — read-only (Claude configuration)

The `RALPH_CLAUDE_CMD` environment variable overrides the entire execution command in both Docker and non-Docker modes.

`--docker` and `--worktree` are orthogonal: Docker bind-mounts whichever directory ralph.sh is running in, whether that's the original repo or a worktree.

## Per-issue branching

Each child issue is implemented on its own branch named `ralph/<issue-number>`. This provides:

- **Isolation** — changes for each issue are on separate branches
- **Reviewability** — PRs are per-issue, not a single monolithic diff
- **Resumability** — if an iteration produces partial progress, the next iteration continues on the same branch
- **Cleanup** — empty branches (created but no commits added) are automatically deleted on failed iterations

Ralph switches back to the base branch between different issues so each issue starts from a clean base.

## Automatic PR creation

When ralph.sh detects that an issue has been closed, it automatically:

1. Pushes `ralph/<N>` to origin
2. Creates a PR via `gh pr create` with:
   - Title: `ralph: <issue-title> (#<issue-number>)`
   - Body: `Closes #<N>`, acceptance criteria, and commit list
   - Base: the branch ralph.sh was invoked on
   - Labels: copied from the issue
3. Switches back to the base branch

Claude never pushes — all remote operations are controlled by ralph.sh.

## Enhanced terminal output

Ralph provides structured status updates:

- **Pre-iteration banner** — shows iteration number, max iterations, issue number and title, branch name, open/closed counts
- **Post-iteration outcome line** — shows iteration number, outcome, duration, and notes (e.g., PR URL)
- **Summary table at exit** — formatted table of all iterations with issue numbers, outcomes, and notes

All status output goes to stderr so it doesn't interfere with log capture.

## Stop conditions

| Exit code | Condition |
|-----------|-----------|
| 0 | All child issues closed — PRD complete |
| 2 | Invalid usage |
| 3 | Dirty working tree |
| 4 | No child issues found for the PRD |
| 5 | Open children exist but none are eligible (blocked) |
| 6 | `--max-iterations` limit reached |
| 7 | Stuck — two consecutive iterations closed zero issues |

## Iteration outcomes

Each iteration ends in exactly one of three states:

- **Closed** — issue fully implemented, committed, closed, PR created, and PRD status updated
- **Partial** — some acceptance criteria met, committed, issue left open for the next iteration
- **Rolled back** — broken code detected, working tree restored to HEAD, no changes persisted

## Safety guarantees

- Claude never pushes (ralph.sh handles all remote operations after review-by-observation)
- Never force-pushes, resets hard, or skips hooks
- Never modifies `.github/` or its own skill files
- Never touches issues outside the current PRD's child set
- Never closes the parent PRD
- Refuses to start on a dirty working tree
- Credentials are mounted read-only in Docker mode

## Logs

Per-iteration logs are written to `.ralph/logs/<prd>/`:
- `iter-NNN-issue-MM.log` — full Claude output for each iteration
- `summary.log` — one-line-per-iteration outcome table (also includes PR URLs when available)

## Tests

```bash
# Run all tests
./test/run.sh              # eligibility module
./test/reporter_test.sh    # terminal reporter
./test/docker_cmd_test.sh  # Docker command builder
./test/branch_mgr_test.sh  # branch manager
./test/pr_creator_test.sh  # PR creator
```
