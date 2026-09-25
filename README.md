# My dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), always run as `stow --no-folding .` so directories like `~/.config` stay real and only individual files are symlinked. Bundles Homebrew formulae, shell/tool configuration, and setup for the CLI coding agents used day to day: Claude Code, Hermes, and Mistral's `vibe`.

## Setup

Clone this repository to `~/.dotfiles` and run the init script:

```shell
git clone <repo-url> ~/.dotfiles
~/.dotfiles/scripts/init.sh
```

`init.sh` installs Homebrew, symlinks everything with stow, installs Node.js (via `fnm`), runs `brew bundle` (which also installs Bun, uv, and the Mistral CLI as a uv tool), then installs Claude Code and Hermes.

## Updating

To update Homebrew packages, uv tools, agent CLIs, and re-run stow:

```shell
~/.dotfiles/scripts/update.sh
```

## What's inside

- `Brewfile` – source of truth for Homebrew formulae, casks, uv tools and npm globals (gh, git, go, bun, uv, pnpm, starship, stow, fnm, copilot-cli, jetbrains-toolbox, orbstack, rectangle, mistral-vibe, …).
- `.zshenv`, `.zprofile`, `.zshrc` – zsh startup, split by when each runs: early env vars, login-shell PATH/tool homes, interactive aliases/prompt/completions.
- `CLAUDE.md`, `docs/agents/` – Claude Code project instructions and agent-skill conventions (issue tracker, domain docs).
- `.config/` – starship, gh, and git config.
- `scripts/init.sh`, `scripts/update.sh` – first-time setup and repeatable updates.

## Manual installs

- [Wispr Flow](https://wisprflow.ai/)