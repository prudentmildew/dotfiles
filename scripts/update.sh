#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Updating and upgrading brew packages..."
brew update && brew upgrade

echo "==> Installing new brew bundle entries..."
brew bundle

echo "==> Upgrading uv tools..."
uv tool upgrade --all

echo "==> Updating Claude Code..."
claude update

echo "==> Updating Hermes..."
hermes update

echo "==> Symlinking dotfiles with stow..."
stow --no-folding --restow .
