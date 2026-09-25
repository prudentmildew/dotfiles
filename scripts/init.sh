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
eval "$(/opt/homebrew/bin/brew shellenv bash)"

# Stow before anything else, so installers that append to ~/.zshrc or
# ~/.zprofile edit the repo's files instead of creating real ones that stow
# would then refuse to replace. --no-folding keeps ~/.config, ~/.claude etc.
# as real directories so tool state never lands in the repo.
echo "==> Symlinking dotfiles with stow..."
brew install stow fnm
stow --no-folding .

# Node must exist before `brew bundle`, which installs the Brewfile's npm entries.
if ! command -v node &> /dev/null; then
  echo "==> Installing Nodejs using fnm..."
  fnm install --latest
else
  echo "Nodejs already installed."
fi
eval "$(fnm env --shell bash)"
node -v

echo "==> Installing brew packages..."
brew bundle

# Is Claude Code installed?
if ! command -v claude &> /dev/null; then
  echo "==> Installing Claude Code via native installer..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude Code is already installed."
  claude -v
fi

# Is Hermes installed?
if ! command -v hermes &> /dev/null; then
  echo "==> Installing Hermes..."
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
else
  echo "Hermes is already installed."
fi
