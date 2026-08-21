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

# Is Nodejs installed?
if ! command -v node &> /dev/null; then
  echo "==> Installing Nodejs using fnm..."
  fnm install --latest
else
  echo "Nodejs already installed."
  node -v
fi

# Is Claude Code installed?
if ! command -v claude &> /dev/null; then
  echo "==> Installing Claude Code via native installer..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude Code is already installed."
  claude -v
fi

# Is Bun installed?
if ! command -v bun &> /dev/null; then
  echo "==> Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
else
  echo "Bun is already installed."
  bun -v
fi

# Is Hermes installed?
if ! command -v hermes &> /dev/null; then
  echo "==> Installing Hermes..."
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
else
  echo "Hermes is already installed."
fi

# Is Mistral CLI installed?
if ! command -v vibe &> /dev/null; then
  echo "==> Installing Mistral CLI..."
  curl -LsSf https://mistral.ai/vibe/install.sh | bash
else
  echo "Mistral CLI is already installed."
fi

echo "==> Symlinking dotfiles with stow..."
stow .