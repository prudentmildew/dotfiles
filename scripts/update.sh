#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Updating and upgrading brew packages..."
brew update && brew upgrade

echo "==> Installing new brew bundle entries..."
brew bundle

echo "==> Updating Claude Code..."
claude update

echo "==> Updating PI..."
npm update -g @mariozechner/pi-coding-agent

echo "==> Upgrading Bun..."
bun upgrade

echo "===> Upgrading Mistral CLI..."
curl -LsSf https://mistral.ai/vibe/install.sh | bash

echo "==> Symlinking dotfiles with stow..."
stow .