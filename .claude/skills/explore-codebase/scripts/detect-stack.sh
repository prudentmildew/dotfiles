#!/usr/bin/env bash
set -euo pipefail

# Detect technology stack by finding and reading config/manifest files.
# Usage: detect-stack.sh <repo-root>

REPO_ROOT="${1:?Usage: detect-stack.sh <repo-root>}"
cd "$REPO_ROOT"

echo "=== DETECTED CONFIG FILES ==="

# Check each known config file/directory and report what it indicates
check_config() {
  local path="$1" label="$2"
  if [[ -d "$path" ]]; then
    echo "  [DIR]  $path -> $label"
  elif [[ -f "$path" ]]; then
    echo "  [FILE] $path -> $label"
  fi
}

check_config "package.json"          "Node.js / JavaScript"
check_config "tsconfig.json"         "TypeScript"
check_config "Cargo.toml"            "Rust"
check_config "go.mod"                "Go"
check_config "pyproject.toml"        "Python (modern)"
check_config "setup.py"              "Python (legacy)"
check_config "requirements.txt"      "Python"
check_config "Pipfile"               "Python (Pipenv)"
check_config "Gemfile"               "Ruby"
check_config "pom.xml"               "Java (Maven)"
check_config "build.gradle"          "Java/Kotlin (Gradle)"
check_config "build.gradle.kts"      "Kotlin (Gradle KTS)"
check_config "mix.exs"               "Elixir"
check_config "pubspec.yaml"          "Dart/Flutter"
check_config "composer.json"         "PHP"
check_config "Package.swift"         "Swift"
check_config "CMakeLists.txt"        "C/C++ (CMake)"
check_config "Makefile"              "Make-based build"
check_config "Dockerfile"            "Docker"
check_config "docker-compose.yml"    "Docker Compose"
check_config "docker-compose.yaml"   "Docker Compose"
check_config ".github/workflows"     "GitHub Actions CI"
check_config ".gitlab-ci.yml"        "GitLab CI"
check_config "Jenkinsfile"           "Jenkins CI"
check_config ".circleci/config.yml"  "CircleCI"
check_config "vercel.json"           "Vercel deployment"
check_config "netlify.toml"          "Netlify deployment"
check_config "fly.toml"              "Fly.io deployment"
check_config "terraform"             "Terraform IaC"
check_config "pulumi"                "Pulumi IaC"
check_config ".env.example"          "Environment config"
check_config "Brewfile"              "Homebrew dependencies"
check_config "flake.nix"             "Nix"
check_config "shell.nix"             "Nix"

# Also find .csproj files in subdirectories
csproj=$(find . -maxdepth 3 -name "*.csproj" -type f 2>/dev/null | head -1)
if [[ -n "$csproj" ]]; then
  echo "  [FIND] $csproj -> C# / .NET"
fi

echo ""
echo "=== DEPENDENCY DETAILS ==="

# Node.js
if [[ -f "package.json" ]]; then
  echo ""
  echo "--- package.json ---"
  echo "Name: $(python3 -c "import json; d=json.load(open('package.json')); print(d.get('name','(unnamed)'))" 2>/dev/null || echo "(parse error)")"
  echo "Description: $(python3 -c "import json; d=json.load(open('package.json')); print(d.get('description',''))" 2>/dev/null || echo "")"

  echo ""
  echo "Dependencies:"
  python3 -c "
import json
d = json.load(open('package.json'))
for dep, ver in sorted(d.get('dependencies', {}).items()):
    print(f'  {dep}: {ver}')
" 2>/dev/null || echo "  (parse error)"

  echo ""
  echo "Dev Dependencies:"
  python3 -c "
import json
d = json.load(open('package.json'))
for dep, ver in sorted(d.get('devDependencies', {}).items()):
    print(f'  {dep}: {ver}')
" 2>/dev/null || echo "  (parse error)"

  echo ""
  echo "Scripts:"
  python3 -c "
import json
d = json.load(open('package.json'))
for name, cmd in sorted(d.get('scripts', {}).items()):
    print(f'  {name}: {cmd}')
" 2>/dev/null || echo "  (parse error)"
fi

# Rust
if [[ -f "Cargo.toml" ]]; then
  echo ""
  echo "--- Cargo.toml ---"
  grep -E '^\[|^name|^version|^edition' Cargo.toml | head -20
  echo ""
  echo "Dependencies:"
  sed -n '/^\[dependencies\]/,/^\[/p' Cargo.toml | grep -v '^\[' | head -30
fi

# Go
if [[ -f "go.mod" ]]; then
  echo ""
  echo "--- go.mod ---"
  head -5 go.mod
  echo ""
  echo "Direct dependencies:"
  grep -v '^\s*//' go.mod | sed -n '/^require/,/^)/p' | grep -v '^require\|^)' | head -30
fi

# Python
if [[ -f "pyproject.toml" ]]; then
  echo ""
  echo "--- pyproject.toml ---"
  head -30 pyproject.toml
fi

if [[ -f "requirements.txt" ]]; then
  echo ""
  echo "--- requirements.txt ---"
  head -30 requirements.txt
fi

# Ruby
if [[ -f "Gemfile" ]]; then
  echo ""
  echo "--- Gemfile (gems) ---"
  grep "^gem " Gemfile | head -30
fi

# Java/Kotlin
if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
  echo ""
  echo "--- Gradle dependencies ---"
  GRADLE_FILE="build.gradle"
  [[ -f "build.gradle.kts" ]] && GRADLE_FILE="build.gradle.kts"
  grep -E 'implementation|api|compile' "$GRADLE_FILE" | head -30
fi

# Docker
if [[ -f "Dockerfile" ]]; then
  echo ""
  echo "--- Dockerfile (FROM lines) ---"
  grep "^FROM" Dockerfile
fi

# Homebrew
if [[ -f "Brewfile" ]]; then
  echo ""
  echo "--- Brewfile ---"
  cat Brewfile
fi

echo ""
echo "=== VERSION FILES ==="
for vf in .node-version .nvmrc .python-version .ruby-version .java-version .tool-versions .sdkmanrc; do
  if [[ -f "$vf" ]]; then
    echo "  $vf: $(cat "$vf")"
  fi
done
