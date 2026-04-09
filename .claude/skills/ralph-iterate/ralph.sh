#!/usr/bin/env bash
# ralph.sh — Ralph autonomous PRD implementation loop controller.
# Usage: ./ralph.sh <prd-number> [--max-iterations N] [--worktree] [--dry-run]
set -euo pipefail

# Source the deep modules.
RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=eligibility.sh
. "$RALPH_DIR/eligibility.sh"
# shellcheck source=docker_cmd.sh
. "$RALPH_DIR/docker_cmd.sh"
# shellcheck source=branch_mgr.sh
. "$RALPH_DIR/branch_mgr.sh"
# shellcheck source=pr_creator.sh
. "$RALPH_DIR/pr_creator.sh"
# shellcheck source=reporter.sh
. "$RALPH_DIR/reporter.sh"

usage() {
  echo "Usage: $0 <prd-number> [--max-iterations N] [--worktree] [--docker] [--brave] [--dry-run]" >&2
  exit 2
}

PRD=""
DRY_RUN=0
MAX_ITERATIONS=50
USE_WORKTREE=0
USE_DOCKER=0
USE_BRAVE=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage ;;
    --dry-run) DRY_RUN=1; shift ;;
    --worktree) USE_WORKTREE=1; shift ;;
    --docker) USE_DOCKER=1; shift ;;
    --brave) USE_BRAVE=1; shift ;;
    --max-iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --max-iterations=*) MAX_ITERATIONS="${1#*=}"; shift ;;
    --) shift; break ;;
    -*)
      echo "ralph: unknown flag: $1" >&2
      usage
      ;;
    *)
      if [ -z "$PRD" ]; then PRD="$1"; else
        echo "ralph: unexpected positional argument: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

if [ -z "$PRD" ]; then
  usage
fi

# Refuse to run on a dirty working tree (applies to dry-run and worktree too).
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "ralph: dirty working tree — commit or stash changes before running" >&2
  exit 3
fi

# Record the base branch — used as the branch point for per-issue branches and PR targets.
base_branch="$(git rev-parse --abbrev-ref HEAD)"

# Optional: sandbox the entire run inside a fresh git worktree of the current
# branch. The worktree is created but never auto-merged or auto-deleted —
# review and merging are deliberate user actions after the run finishes.
if [ "$USE_WORKTREE" -eq 1 ]; then
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  ts="$(date +%Y%m%d-%H%M%S)"
  wt_path=".ralph/worktrees/${PRD}-${ts}"
  mkdir -p ".ralph/worktrees"
  echo "ralph: creating worktree at $wt_path from branch $current_branch"
  git worktree add "$wt_path" "$current_branch" >&2
  abs_wt="$(cd "$wt_path" && pwd)"
  # On exit, print the worktree path so the user knows where to look.
  trap 'echo "ralph: worktree left at $abs_wt (not auto-merged, not auto-deleted)"' EXIT
  cd "$abs_wt"
fi

# Pick the next eligible issue using the deep eligibility module.
pick_next() {
  local prd="$1"
  eligibility "$prd" | head -1
}

# Count open children (uses the same gh query path as eligibility, via $GH).
open_children_count() {
  local prd="$1"
  "${GH:-gh}" issue list --state open --limit 200 --json number,body \
    | jq --arg p "$prd" '[.[] | select(.body | test("## Parent PRD\\s*\\n+#" + $p + "\\b"))] | length'
}

# Count children at all (open + closed).
all_children_count() {
  local prd="$1"
  "${GH:-gh}" issue list --state all --limit 200 --json number,body \
    | jq --arg p "$prd" '[.[] | select(.body | test("## Parent PRD\\s*\\n+#" + $p + "\\b"))] | length'
}

if [ "$DRY_RUN" -eq 1 ]; then
  next="$(pick_next "$PRD" || true)"
  if [ -n "$next" ]; then
    title="$("${GH:-gh}" issue view "$next" --json title -q .title 2>/dev/null || echo "")"
    echo "ralph: dry-run — would pick #$next ${title:+($title)}"
    if [ "$USE_DOCKER" -eq 1 ]; then
      repo_dir="$(pwd)"
      echo "ralph: docker command — $(build_claude_cmd 1 "$USE_BRAVE" "$repo_dir" "-p \"/ralph-iterate $PRD $next\"")"
    fi
    exit 0
  fi
  total="$(all_children_count "$PRD" 2>/dev/null || echo 0)"
  open="$(open_children_count "$PRD" 2>/dev/null || echo 0)"
  if [ "$total" = "0" ]; then
    echo "ralph: no children found for PRD #$PRD" >&2
    exit 4
  fi
  if [ "$open" = "0" ]; then
    echo "ralph: PRD #$PRD complete — all children closed"
    exit 0
  fi
  echo "ralph: blocked — open children remain for PRD #$PRD but none are eligible" >&2
  exit 5
fi

# ─────────────────────────────────────────────────────────────────────────────
# Loop with stop conditions (priority order):
#   1. dirty tree              → already exited above (exit 3)
#   2. --max-iterations reached → exit 6
#   3. all children closed     → exit 0 ("PRD complete")
#   4. open children, none eligible → exit 5 ("blocked")
#   5. two consecutive zero-close iterations → exit 7 ("stuck")
# A "zero-close iteration" is one in which the open-children count did not
# decrease. Partial-progress iterations (commit + tick but no close) are
# zero-close iterations on their own — but only CONSECUTIVE zero-close
# iterations trip the stuck detector, so partial→close is a happy path.
# ─────────────────────────────────────────────────────────────────────────────

iter=0
consecutive_zero=0
prev_open=""
prev_issue=""
repo_dir="$(pwd)"

# Print summary table on any exit from the loop.
trap 'summary_table' EXIT

while :; do
  # Stop condition 2: max-iterations.
  if [ "$iter" -ge "$MAX_ITERATIONS" ]; then
    echo "ralph: max-iterations ($MAX_ITERATIONS) reached" >&2
    exit 6
  fi

  # Recompute counts and pick next.
  total="$(all_children_count "$PRD" 2>/dev/null || echo 0)"
  if [ "$total" = "0" ]; then
    echo "ralph: no children found for PRD #$PRD" >&2
    exit 4
  fi
  open="$(open_children_count "$PRD" 2>/dev/null || echo 0)"
  closed=$((total - open))

  # Stop condition 3: all closed.
  if [ "$open" = "0" ]; then
    echo "ralph: PRD #$PRD complete — all children closed"
    exit 0
  fi

  # Stop condition 4: open but none eligible.
  next="$(pick_next "$PRD" || true)"
  if [ -z "$next" ]; then
    echo "ralph: blocked — open children remain for PRD #$PRD but none are eligible" >&2
    exit 5
  fi

  # Track stuck-detector state from the PREVIOUS iteration's outcome.
  if [ -n "$prev_open" ]; then
    if [ "$open" -ge "$prev_open" ]; then
      consecutive_zero=$((consecutive_zero + 1))
    else
      consecutive_zero=0
    fi
    # Stop condition 5: two consecutive zero-close iterations.
    if [ "$consecutive_zero" -ge 2 ]; then
      echo "ralph: stuck — two consecutive iterations closed zero issues" >&2
      exit 7
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    title="$("${GH:-gh}" issue view "$next" --json title -q .title 2>/dev/null || echo "")"
    echo "ralph: dry-run — would pick #$next ${title:+($title)}"
    exit 0
  fi

  iter=$((iter + 1))

  # Per-issue branching: switch to issue branch (return to base first if different issue).
  if [ -n "$prev_issue" ] && [ "$prev_issue" != "$next" ]; then
    return_to_base "$base_branch"
  fi
  issue_branch="$(ensure_branch "$next" "$base_branch")"
  prev_issue="$next"

  # Logging: ensure per-PRD log dir exists, build per-iteration log path.
  log_dir=".ralph/logs/$PRD"
  mkdir -p "$log_dir"
  printf -v iter_padded "%03d" "$iter"
  iter_log="$log_dir/iter-${iter_padded}-issue-${next}.log"
  summary_log="$log_dir/summary.log"

  # Fetch issue title for banner.
  issue_title="$("${GH:-gh}" issue view "$next" --json title -q .title 2>/dev/null || echo "issue #$next")"
  banner "$iter" "$MAX_ITERATIONS" "$next" "$issue_title" "$issue_branch" "$open" "$closed"

  head_before_iter="$(git rev-parse HEAD 2>/dev/null || echo "")"
  iter_start=$(date +%s)

  # Build and execute the Claude command.
  prompt_args="-p \"/ralph-iterate $PRD $next\""
  claude_cmd="$(build_claude_cmd "$USE_DOCKER" "$USE_BRAVE" "$repo_dir" "$prompt_args")"

  # tee preserves live terminal output AND persists the full stream.
  set +e
  eval "$claude_cmd" 2>&1 | tee "$iter_log"
  set -e
  iter_end=$(date +%s)
  iter_dur=$((iter_end - iter_start))

  # Determine outcome from observable state, not from claude's exit code:
  #   closed  → open count strictly decreased
  #   partial → open count unchanged AND a new commit exists for this iter
  #   failed  → otherwise (e.g. rollback, claude crash, no progress)
  new_open="$(open_children_count "$PRD" 2>/dev/null || echo "$open")"
  iter_notes=""
  if [ "$new_open" -lt "$open" ]; then
    outcome="closed"
    # Auto-create PR for closed issues.
    pr_url="$(create_pr "$next" "$base_branch" 2>/dev/null || echo "")"
    if [ -n "$pr_url" ]; then
      iter_notes="$pr_url"
    fi
    return_to_base "$base_branch"
  else
    # Detect a new commit by comparing HEAD to the head we recorded.
    head_now="$(git rev-parse HEAD 2>/dev/null || echo "")"
    if [ -n "${head_before_iter:-}" ] && [ "$head_now" != "$head_before_iter" ]; then
      outcome="partial"
    else
      outcome="failed"
      # Clean up empty branch on failure, return to base.
      cleanup_empty_branch "$next" "$base_branch" "$head_before_iter" 2>/dev/null || true
      return_to_base "$base_branch"
    fi
  fi

  # Record outcome in reporter and summary log.
  outcome_line "$iter" "$next" "$outcome" "$iter_dur" "$iter_notes"
  printf 'iter %s | issue #%s | %s | %ss%s\n' "$iter_padded" "$next" "$outcome" "$iter_dur" \
    "${iter_notes:+ | $iter_notes}" >> "$summary_log"

  prev_open="$open"
  open="$new_open"
done
