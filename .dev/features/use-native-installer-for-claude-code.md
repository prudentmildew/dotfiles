# Feature: Use Native Installer for Claude Code

This file describes the need for using the native installer for Claude Code instead of the Brew installer.

## Motivation

Claude Code is a powerful tool that requires specific dependencies and configurations to function optimally. The native installer provides a more streamlined, updated and reliable way to set up these dependencies compared to the Brew installer, which can sometimes lag behind when new versions are made available.



## Implementation
The native installer will be used for Claude Code. This decision is based on the need for a more consistent and up-to-date environment for Claude Code, ensuring optimal performance and compatibility with the latest features and bug fixes. An `init.sh` will be created to automate the init process, running the `brew bundle` command, the `stow .` command and `curl -fsSL https://claude.ai/install.sh | bash`. An `update.sh` script will be created to automate the update process.

## Acceptance Criteria
- [x] The native installer is used to install Claude Code when bootstrapping the environment.
- [x] The native installer is used to update Claude Code when updating the environment.
- [x] Update the README to reflect the use of the init script.
- [x] Update the README to reflect the use of the update script.

## References
- [Claude Code Installation Guide](https://docs.anthropic.com/claude/docs/installation)
- [Local copy of zsh Docs](../../.dev/zsh-5.9/Doc/index.html)