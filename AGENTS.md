# AGENTS.md

## Overview

A personal macOS dotfiles repo managed with [GNU Stow](https://www.gnu.org/software/stow/). The repo **must be cloned to `~/.dotfiles`** — Stow uses the parent directory (`~`) as the symlink target, so directory structure under `~/.dotfiles/` maps directly to `~/`.

## Key Architecture

- **`Brewfile`** — single source of truth for all Homebrew formulae and casks.
- **`scripts/init.sh`** — one-shot bootstrap: installs Homebrew → `brew bundle` → Claude Code → Bun → Ollama → `stow .`
- **`scripts/update.sh`** — idempotent updater: `brew update && brew upgrade` → `brew bundle` → Claude Code → Bun → Ollama → `stow .`
- **`stow .`** — run from repo root; creates symlinks in `~` for every file tracked in the repo. Re-running is safe and picks up new files.

## Developer Workflows

| Task | Command |
|---|---|
| Bootstrap a new machine | `~/.dotfiles/scripts/init.sh` |
| Pull updates & re-link | `~/.dotfiles/scripts/update.sh` |
| Add a new dotfile | Place file under `~/.dotfiles/` mirroring its `~/` path, then run `stow .` |
| Add a Homebrew package | Add entry to `Brewfile`, then `brew bundle` |

## Conventions

- Scripts start with `set -euo pipefail` and `cd "$(dirname "$0")/.."` to ensure repo-root-relative execution.
- Tools **not** managed by Homebrew (Claude Code, Bun, Ollama) are installed via their official `curl | bash` installers and updated explicitly in `update.sh`.
- Node.js is managed by **`fnm`** (not `nvm`) — see `Brewfile`.
- No dotfile content lives outside this repo; everything is symlinked, never copied.
