#!/usr/bin/env bash
# reporter.sh — deep module: structured terminal output for Ralph loop.
#
# Provides: banner(), outcome_line(), summary_table()
# Stores iteration results in RALPH_RESULTS array for the final table.
#
# All output goes to stderr so it doesn't interfere with stdout data flow.

# Accumulated results: each entry is "iter|issue|outcome|duration|notes"
RALPH_RESULTS=()

# banner <iter> <max_iter> <issue> <title> <branch> <open> <closed>
# Prints a formatted status block before each iteration.
banner() {
  local iter="$1" max_iter="$2" issue="$3" title="$4" branch="$5" open="$6" closed="$7"
  local display_branch="${branch:-current}"
  cat >&2 <<EOF
═══════════════════════════════════════════════════════════════════════
  ralph: iteration ${iter}/${max_iter}
  issue:  #${issue} — ${title}
  branch: ${display_branch}
  open: ${open}  closed: ${closed}
═══════════════════════════════════════════════════════════════════════
EOF
}

# outcome_line <iter> <issue> <outcome> <duration> [notes]
# Prints a one-line result after each iteration and stores it.
outcome_line() {
  local iter="$1" issue="$2" outcome="$3" duration="$4" notes="${5:-}"
  RALPH_RESULTS+=("${iter}|${issue}|${outcome}|${duration}|${notes}")
  printf '  → iter %s | #%s | %s | %ss%s\n' \
    "$iter" "$issue" "$outcome" "$duration" \
    "${notes:+ | $notes}" >&2
}

# summary_table
# Prints a formatted table of all iteration results at loop exit.
summary_table() {
  if [ ${#RALPH_RESULTS[@]} -eq 0 ]; then
    echo "No iterations completed." >&2
    return
  fi
  printf '\n' >&2
  printf '%-6s %-8s %-10s %-8s %s\n' "ITER" "ISSUE" "OUTCOME" "TIME" "NOTES" >&2
  printf '%-6s %-8s %-10s %-8s %s\n' "----" "-----" "-------" "----" "-----" >&2
  local entry
  for entry in "${RALPH_RESULTS[@]}"; do
    IFS='|' read -r iter issue outcome duration notes <<< "$entry"
    printf '%-6s %-8s %-10s %-8s %s\n' "$iter" "#${issue}" "$outcome" "${duration}s" "$notes" >&2
  done
}
