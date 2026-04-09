#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Updating and upgrading brew packages..."
brew update && brew upgrade

echo "==> Installing new brew bundle entries..."
brew bundle

echo "==> Symlinking dotfiles with stow..."
stow .

echo "==> Updating Claude Code via native installer..."
curl -fsSL https://claude.ai/install.sh | bash
