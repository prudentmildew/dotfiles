# AGENTS.md

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Clone to `~/.dotfiles`; `stow .` symlinks this tree into `~/`.

## Rules

- `Brewfile` is the source of truth for Homebrew formulae and casks.
- `scripts/init.sh` is for first-time setup: install Homebrew, run `brew bundle`, install Claude Code, Bun, and Ollama, then run `stow .`.
- `scripts/update.sh` is for repeatable updates: run `brew upgrade`, `brew bundle`, update Claude Code, Bun, and Ollama, then run `stow .`.
- Shell scripts must use `set -euo pipefail` and `cd` to the repo root.
- Use `fnm` for Node.js, never `nvm`.
- Keep files in paths that mirror `~/`; symlink with Stow, never copy.
