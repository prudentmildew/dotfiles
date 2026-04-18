#!/usr/bin/env bash
# save-synthesis.sh — write an ideation synthesis to ideas/<date>-<slug>.md
#
# Usage:
#   ./save-synthesis.sh [--title "Idea title"] [--dir path] < synthesis.md
#   echo "# My Idea ..." | ./save-synthesis.sh
#
# Behavior:
#   - Target directory: $IDEATE_DIR if set, else --dir, else ./ideas
#   - Title: --title flag, else first `# H1` in the piped content, else "untitled"
#   - Filename: YYYY-MM-DD-<slug>.md, where slug is title lowercased,
#     non-alphanumerics → hyphens, capped at 50 chars.
#   - Collisions get -2, -3, … suffixes (never overwrites).
#   - Prints the final absolute path to stdout on success.

set -euo pipefail

title=""
dir="${IDEATE_DIR:-./ideas}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) title="${2:-}"; shift 2 ;;
    --dir)   dir="${2:-}";   shift 2 ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "save-synthesis.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# Read all of stdin into $content.
if [[ -t 0 ]]; then
  echo "save-synthesis.sh: expected synthesis content on stdin" >&2
  exit 2
fi
content="$(cat)"

if [[ -z "${content//[[:space:]]/}" ]]; then
  echo "save-synthesis.sh: stdin was empty" >&2
  exit 2
fi

# Fall back to the first H1 in the content if no --title was given.
if [[ -z "$title" ]]; then
  title="$(printf '%s\n' "$content" | awk '/^# +/ { sub(/^# +/, ""); print; exit }')"
fi
[[ -z "$title" ]] && title="untitled"

# Slugify: lowercase, non-alnum → '-', squeeze repeats, trim.
slug="$(printf '%s' "$title" \
  | tr '[:upper:]' '[:lower:]' \
  | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

# Cap length at 50. If the cut lands mid-word, back off to the last hyphen
# boundary so we don't truncate like '...failure-memor'.
if [[ ${#slug} -gt 50 ]]; then
  next="${slug:50:1}"
  slug="${slug:0:50}"
  if [[ "$next" =~ [a-z0-9] && "$slug" == *-* ]]; then
    slug="${slug%-*}"
  fi
  slug="${slug%-}"
fi
[[ -z "$slug" ]] && slug="untitled"

mkdir -p "$dir"

date_prefix="$(date +%Y-%m-%d)"
base="$dir/${date_prefix}-${slug}"
path="${base}.md"
n=2
while [[ -e "$path" ]]; do
  path="${base}-${n}.md"
  n=$((n + 1))
done

printf '%s\n' "$content" > "$path"

# Resolve to an absolute path portably (works on macOS without `realpath`).
abs="$(cd "$(dirname "$path")" && printf '%s/%s' "$(pwd -P)" "$(basename "$path")")"
printf '%s\n' "$abs"
