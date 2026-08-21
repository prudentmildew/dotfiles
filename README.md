# My dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Bundles Homebrew formulae, shell/tool configuration, and setup for the CLI coding agents used day to day: Claude Code, [PI](https://www.npmjs.com/package/@mariozechner/pi-coding-agent), Hermes, and Mistral's `vibe`.

## Setup

Clone this repository to `~/.dotfiles` and run the init script:

```shell
git clone <repo-url> ~/.dotfiles
~/.dotfiles/scripts/init.sh
```

`init.sh` installs Homebrew, runs `brew bundle`, then installs Node.js (via `fnm`), Claude Code, PI, Bun, Hermes, and the Mistral CLI before symlinking everything with `stow .`.

## Updating

To update Homebrew packages, agent CLIs, and re-run stow:

```shell
~/.dotfiles/scripts/update.sh
```

## What's inside

- `Brewfile` – source of truth for Homebrew formulae and casks (gh, git, go, pnpm, starship, stow, fnm, copilot-cli, jetbrains-toolbox, orbstack, rectangle, …).
- `CLAUDE.md`, `docs/agents/` – Claude Code project instructions and agent-skill conventions (issue tracker, domain docs).
- `.config/` – starship, gh, git, github-copilot config.
- `scripts/init.sh`, `scripts/update.sh` – first-time setup and repeatable updates.

## Manual installs

- [Wispr Flow](https://wisprflow.ai/)