#!/usr/bin/env bash
set -euo pipefail

# Find application entrypoints, route definitions, and CLI entry points.
# Usage: find-entrypoints.sh <repo-root>

REPO_ROOT="${1:?Usage: find-entrypoints.sh <repo-root>}"
cd "$REPO_ROOT"

EXCLUDE_DIRS=".git node_modules vendor dist build target __pycache__ .venv venv .next"
FIND_PRUNE=""
for d in $EXCLUDE_DIRS; do
  FIND_PRUNE="$FIND_PRUNE -path ./$d -prune -o"
done

echo "=== MAIN / ENTRY FILES ==="
# Common entrypoint filenames
ENTRY_PATTERNS=(
  "main.go" "main.rs" "main.py" "main.ts" "main.js" "main.tsx" "main.jsx"
  "index.ts" "index.js" "index.tsx" "index.jsx"
  "app.ts" "app.js" "app.py" "app.rb"
  "server.ts" "server.js" "server.py"
  "cli.ts" "cli.js" "cli.py"
  "mod.rs" "lib.rs"
  "manage.py" "wsgi.py" "asgi.py"
  "Program.cs" "Startup.cs"
  "Application.java" "App.java"
)

for pattern in "${ENTRY_PATTERNS[@]}"; do
  results=$(eval "find . $FIND_PRUNE -name '$pattern' -type f -print" 2>/dev/null)
  if [[ -n "$results" ]]; then
    echo "$results" | sed 's|^\./||'
  fi
done | sort -u

echo ""
echo "=== ROUTE / ENDPOINT DEFINITIONS ==="

# Search for common routing patterns
echo "-- Express/Fastify/Koa routes --"
eval "find . $FIND_PRUNE -type f \( -name '*.ts' -o -name '*.js' \) -print" 2>/dev/null | \
  xargs grep -l 'router\.\(get\|post\|put\|delete\|patch\)\|app\.\(get\|post\|put\|delete\|patch\)' 2>/dev/null | \
  sed 's|^\./||' | sort || true

echo ""
echo "-- Next.js / file-based routes --"
for dir in pages app src/pages src/app; do
  if [[ -d "$dir" ]]; then
    echo "  File-based routing in: $dir/"
    find "$dir" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) | \
      grep -v '_app\|_document\|layout\|loading\|error\|not-found' | \
      sed 's|^\./||' | sort | head -30
  fi
done

echo ""
echo "-- Python routes (Flask/Django/FastAPI) --"
eval "find . $FIND_PRUNE -type f -name '*.py' -print" 2>/dev/null | \
  xargs grep -l '@app\.route\|@router\.\|urlpatterns\|@app\.\(get\|post\|put\|delete\)' 2>/dev/null | \
  sed 's|^\./||' | sort || true

echo ""
echo "-- Go routes (net/http, gin, chi, echo) --"
eval "find . $FIND_PRUNE -type f -name '*.go' -print" 2>/dev/null | \
  xargs grep -l 'HandleFunc\|Handle\|\.GET\|\.POST\|\.PUT\|\.DELETE\|Group(' 2>/dev/null | \
  sed 's|^\./||' | sort || true

echo ""
echo "-- Ruby routes (Rails) --"
if [[ -f "config/routes.rb" ]]; then
  echo "  config/routes.rb"
fi

echo ""
echo "-- Java/Kotlin routes (Spring) --"
eval "find . $FIND_PRUNE -type f \( -name '*.java' -o -name '*.kt' \) -print" 2>/dev/null | \
  xargs grep -l '@RequestMapping\|@GetMapping\|@PostMapping\|@RestController' 2>/dev/null | \
  sed 's|^\./||' | sort || true

echo ""
echo "=== CONFIG / INFRASTRUCTURE FILES ==="
CONFIG_PATTERNS=(
  "*.config.ts" "*.config.js" "*.config.mjs" "*.config.cjs"
  ".eslintrc*" ".prettierrc*" "jest.config*" "vitest.config*"
  "webpack.config*" "vite.config*" "rollup.config*" "esbuild*"
  "nginx.conf" "Procfile" "Caddyfile"
)

for pattern in "${CONFIG_PATTERNS[@]}"; do
  eval "find . -maxdepth 3 $FIND_PRUNE -name '$pattern' -type f -print" 2>/dev/null | \
    sed 's|^\./||'
done | sort -u

echo ""
echo "=== TEST DIRECTORIES ==="
for dir in test tests spec __tests__ e2e cypress; do
  if [[ -d "$dir" ]]; then
    count=$(find "$dir" -type f | wc -l | tr -d ' ')
    echo "  $dir/ ($count files)"
  fi
done

# Also check for test files alongside source
TEST_FILES=$(eval "find . $FIND_PRUNE -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.go' -o -name '*_test.py' -o -name 'test_*.py' \) -print" 2>/dev/null | wc -l | tr -d ' ')
echo "  Colocated test files: $TEST_FILES"
