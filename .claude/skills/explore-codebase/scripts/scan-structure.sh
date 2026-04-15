#!/usr/bin/env bash
set -euo pipefail

# Scan a repository's structure: directory tree, file counts by extension, and LOC.
# Usage: scan-structure.sh <repo-root>

REPO_ROOT="${1:?Usage: scan-structure.sh <repo-root>}"
cd "$REPO_ROOT"

echo "=== DIRECTORY TREE (depth 3) ==="
find . -maxdepth 3 -type d \
  ! -path './.git*' \
  ! -path './node_modules*' \
  ! -path './.next*' \
  ! -path './vendor*' \
  ! -path './dist*' \
  ! -path './build*' \
  ! -path './__pycache__*' \
  ! -path './.venv*' \
  ! -path './venv*' \
  ! -path './target*' \
  ! -path './.claude*' \
  | sort | sed 's|[^/]*/|  |g'

echo ""
echo "=== TOP-LEVEL FILES ==="
find . -maxdepth 1 -type f | sort | sed 's|^\./||'

echo ""
echo "=== FILE COUNTS BY EXTENSION ==="
find . -type f \
  ! -path './.git/*' \
  ! -path './node_modules/*' \
  ! -path './.next/*' \
  ! -path './vendor/*' \
  ! -path './dist/*' \
  ! -path './build/*' \
  ! -path './__pycache__/*' \
  ! -path './.venv/*' \
  ! -path './venv/*' \
  ! -path './target/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -30

echo ""
echo "=== TOTAL FILES AND LINES ==="
FILE_COUNT=$(find . -type f \
  ! -path './.git/*' \
  ! -path './node_modules/*' \
  ! -path './vendor/*' \
  ! -path './dist/*' \
  ! -path './build/*' \
  ! -path './target/*' \
  | wc -l | tr -d ' ')
echo "Total files: $FILE_COUNT"

# LOC estimate — count lines in text files, skip binaries
LOC=$(find . -type f \
  ! -path './.git/*' \
  ! -path './node_modules/*' \
  ! -path './vendor/*' \
  ! -path './dist/*' \
  ! -path './build/*' \
  ! -path './target/*' \
  \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
     -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' \
     -o -name '*.rb' -o -name '*.c' -o -name '*.cpp' -o -name '*.h' \
     -o -name '*.cs' -o -name '*.swift' -o -name '*.kt' -o -name '*.scala' \
     -o -name '*.sh' -o -name '*.zsh' -o -name '*.bash' \
     -o -name '*.html' -o -name '*.css' -o -name '*.scss' \
     -o -name '*.sql' -o -name '*.yaml' -o -name '*.yml' -o -name '*.toml' \
     -o -name '*.json' -o -name '*.xml' -o -name '*.md' \) \
  -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
echo "Total LOC (source + config): $LOC"

echo ""
echo "=== LARGEST DIRECTORIES (by file count) ==="
find . -type f \
  ! -path './.git/*' \
  ! -path './node_modules/*' \
  ! -path './vendor/*' \
  ! -path './dist/*' \
  ! -path './build/*' \
  ! -path './target/*' \
  | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -15
