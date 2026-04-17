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

# Is PI installed?
if ! command -v pi &> /dev/null; then
  echo "==> Installing PI using npm..."
  npm install -g @mariozechner/pi-coding-agent
else
  echo "PI is already installed."
  pi -v
fi

# Is Bun installed?
if ! command -v bun &> /dev/null; then
  echo "==> Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
else
  echo "Bun is already installed."
  bun -v
fi

# Is Ollama installed?
if ! command -v ollama &> /dev/null; then
  echo "==> Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
else
  echo "Ollama is already installed."
  ollama -v
fi

echo "==> Symlinking dotfiles with stow..."
stow .