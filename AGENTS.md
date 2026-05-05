# AGENTS.md

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Clone to `~/.dotfiles`; `stow .` symlinks this tree into `~/`.

## Rules

- `Brewfile` is the source of truth for Homebrew formulae and casks.
- `scripts/init.sh` is for first-time setup: install Homebrew, run `brew bundle`, install Claude Code, PI, Bun, and Ollama, then run `stow .`.
- `scripts/update.sh` is for repeatable updates: run `brew upgrade`, `brew bundle`, update Claude Code, PI, Bun, and Ollama, then run `stow .`.
- Claude Code skills for agent workflows live in `.claude/skills/`; see `.claude/AGENTS.md` for the local workflow and skill listing.
- Shell scripts must use `set -euo pipefail` and `cd` to the repo root.
- Use `fnm` for Node.js, never `nvm`.
- Keep files in paths that mirror `~/`; symlink with Stow, never copy.
