#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Is Homebrew installed?
if ! command -v brew &> /dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

echo "==> Installing brew packages..."
brew bundle

# Is Claude Code installed?
if ! command -v claude &> /dev/null; then
  echo "==> Installing Claude Code via native installer..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude Code is already installed."
fi

# Is Bun installed?
if ! command -v bun &> /dev/null; then
  echo "==> Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
else
  echo "Bun is already installed."
fi

echo "==> Symlinking dotfiles with stow..."
stow .