# My dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Bundles Homebrew formulae, agent configs, and skills for the [PI coding agent](https://www.npmjs.com/package/@mariozechner/pi-coding-agent).

## Setup

Clone this repository to `~/.dotfiles` and run the init script:

```shell
git clone <repo-url> ~/.dotfiles
~/.dotfiles/scripts/init.sh
```

`init.sh` installs Homebrew, runs `brew bundle`, then installs Node.js (via `fnm`), Claude Code, PI, Bun, and Ollama before symlinking everything with `stow .`.

## Updating

To update Homebrew packages, agent CLIs, and re-run stow:

```shell
~/.dotfiles/scripts/update.sh
```

## What's inside

- `Brewfile` – source of truth for Homebrew formulae and casks (gh, git, go, pnpm, starship, stow, fnm, copilot-cli, jetbrains-toolbox, orbstack, rectangle, …).
- `.claude/` – Claude Code settings and statusline.
- `.pi/agent/` – PI agent settings, model definitions, and skills (`caveman`, `grill-me`, `ideate`).
- `.config/` – starship, gh, git, github-copilot config.
- `scripts/init.sh`, `scripts/update.sh` – first-time setup and repeatable updates.

See [AGENTS.md](./AGENTS.md) for the full set of repo conventions.

## Manual installs

- [Wispr Flow](https://wisprflow.ai/)