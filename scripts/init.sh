#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Installing brew packages..."
brew bundle

echo "==> Symlinking dotfiles with stow..."
stow .

echo "==> Installing Claude Code via native installer..."
curl -fsSL https://claude.ai/install.sh | bash
