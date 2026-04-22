# My dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Also ships a Claude Code skills library for agent-driven development workflows.

## Setup

Clone this repository to `~/.dotfiles` and run the init script:

```shell
git clone <repo-url> ~/.dotfiles
~/.dotfiles/scripts/init.sh
```

## Updating

To update Homebrew packages, dotfile symlinks, and Claude Code:

```shell
~/.dotfiles/scripts/update.sh
```

## Skills

Reusable Claude Code skills live in `.claude/skills/`. See [.claude/AGENTS.md](.claude/AGENTS.md) for the full workflow and skill listing.

## Manual installs
- [Wispr Flow](https://wisprflow.ai/)
- [Cytoscape](https://cytoscape.org/download.html)
- [LM Studio](https://lmstudio.ai/)