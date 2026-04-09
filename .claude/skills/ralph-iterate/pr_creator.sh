#!/usr/bin/env bash
# pr_creator.sh — deep module: automatic PR creation after issue closure.
#
# Provides: create_pr()
# Pushes the issue branch, fetches issue metadata, and creates a PR via gh.
# Uses ${GH:-gh} and ${GIT:-git} for testability.

# create_pr <issue_number> <base_branch>
# Pushes ralph/<N>, creates PR with title, body (Closes link, acceptance
# criteria, commit list), and copies labels from issue.
# Prints the PR URL to stdout.
create_pr() {
  local issue="$1" base="$2"
  local branch="ralph/${issue}"
  local gh="${GH:-gh}"
  local git="${GIT:-git}"

  # 1. Push branch
  $git push -u origin "$branch"

  # 2. Fetch issue metadata
  local title body labels_json
  title="$($gh issue view "$issue" --json title -q .title 2>/dev/null || echo "Issue #${issue}")"
  body="$($gh issue view "$issue" --json body -q .body 2>/dev/null || echo "")"
  labels_json="$($gh issue view "$issue" --json labels -q '.labels' 2>/dev/null || echo "[]")"

  # 3. Extract acceptance criteria (all - [x] and - [ ] lines)
  local criteria
  criteria="$(printf '%s\n' "$body" | awk '/^## Acceptance criteria/{flag=1; next} /^## /{flag=0} flag' | grep -E '^\s*- \[' || true)"

  # 4. Get commit list
  local commits
  commits="$($git log --oneline "${base}..${branch}" 2>/dev/null || echo "(no commits)")"

  # 5. Build PR body
  local pr_body
  pr_body="$(cat <<BODY
Closes #${issue}

## Acceptance Criteria

${criteria:-None}

## Commits

${commits}
BODY
)"

  # 6. Extract label names for --label flags
  local label_flags=""
  local label_name
  while IFS= read -r label_name; do
    [ -z "$label_name" ] && continue
    label_flags="$label_flags --label $label_name"
  done < <(echo "$labels_json" | jq -r '.[].name' 2>/dev/null || true)

  # 7. Create PR
  local pr_title="ralph: ${title} (#${issue})"
  # shellcheck disable=SC2086
  $gh pr create \
    --base "$base" \
    --head "$branch" \
    --title "$pr_title" \
    --body "$pr_body" \
    $label_flags
}
