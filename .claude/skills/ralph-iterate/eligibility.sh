#!/usr/bin/env bash
# eligibility.sh — deep module: pick eligible open child issues of a PRD.
#
# Input: PRD issue number (positional).
# Output: ascending list of eligible open child issue numbers (one per line).
# Side effects: shells out to ${GH:-gh}.
#
# Eligibility rules (see PRD #1 'Module: eligibility (deep)'):
#   - issue body has a `## Parent PRD` section whose first `#<n>` reference == PRD
#   - issue is OPEN
#   - every `#<n>` in the issue's `## Blocked by` section is CLOSED
#
# `gh` is invoked via ${GH:-gh} so tests can stub it.

eligibility() {
  local prd="$1"
  if [ -z "$prd" ]; then
    echo "eligibility: missing prd argument" >&2
    return 2
  fi

  local raw
  raw="$("${GH:-gh}" issue list --state all --limit 200 --json number,state,body)" || return 1

  # State map: number -> OPEN|CLOSED. Issue numbers are numeric so an
  # indexed array works without requiring bash 4 associative arrays.
  local STATE=()
  local n s
  while IFS=$'\t' read -r n s; do
    [ -n "$n" ] && STATE[$n]="$s"
  done < <(echo "$raw" | jq -r '.[] | "\(.number)\t\(.state)"')

  local results=()
  local num body parent blockers eligible b section
  # Use base64 to safely transport multi-line bodies through TSV.
  while IFS=$'\t' read -r num body; do
    [ -z "$num" ] && continue
    [ "${STATE[$num]:-}" = "OPEN" ] || continue
    body="$(echo "$body" | base64 -d 2>/dev/null || echo "")"

    # Parent PRD check: extract first '#<n>' under '## Parent PRD' header.
    section="$(printf '%s\n' "$body" | awk '/^## Parent PRD[[:space:]]*$/{flag=1; next} /^## /{flag=0} flag')"
    parent="$(printf '%s' "$section" | grep -oE '#[0-9]+' | head -1 | tr -d '#')"
    [ "$parent" = "$prd" ] || continue

    # Blocked by check.
    section="$(printf '%s\n' "$body" | awk '/^## Blocked by[[:space:]]*$/{flag=1; next} /^## /{flag=0} flag')"
    blockers="$(printf '%s' "$section" | grep -oE '#[0-9]+' | tr -d '#' || true)"
    eligible=1
    for b in $blockers; do
      if [ "${STATE[$b]:-OPEN}" != "CLOSED" ]; then
        eligible=0
        break
      fi
    done
    [ $eligible -eq 1 ] && results+=("$num")
  done < <(echo "$raw" | jq -r '.[] | "\(.number)\t\(.body | @base64)"')

  if [ ${#results[@]} -gt 0 ]; then
    printf '%s\n' "${results[@]}" | sort -n
  fi
}
