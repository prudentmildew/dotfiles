# AGENTS.md

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). **Must be cloned to `~/.dotfiles`** — Stow symlinks the repo's directory structure directly into `~/`.

## Key Files

- **`Brewfile`** — source of truth for Homebrew formulae and casks.
- **`scripts/init.sh`** — one-shot bootstrap: Homebrew → `brew bundle` → Claude Code, Bun, Ollama → `stow .`
- **`scripts/update.sh`** — idempotent updater: `brew upgrade` → `brew bundle` → Claude Code, Bun, Ollama → `stow .`

## Conventions

- Scripts use `set -euo pipefail` and `cd` to repo root.
- Non-Homebrew tools (Claude Code, Bun, Ollama) use their official `curl | bash` installers.
- Node.js via **fnm** (not nvm).
- Everything symlinked, never copied. To add a dotfile: place it mirroring its `~/` path, then `stow .`
