# Login-shell environment (PATH, tool homes). Runs once per login, after
# /etc/zprofile's path_helper and before .zshrc.

eval "$(/opt/homebrew/bin/brew shellenv zsh)"

export PNPM_HOME="$HOME/Library/pnpm"
export BUN_INSTALL="$HOME/.bun"

typeset -U path
path=("$BUN_INSTALL/bin" "$HOME/.local/bin" "$PNPM_HOME" $path)

# Added by Toolbox App
export PATH="$PATH:/Users/erland/Library/Application Support/JetBrains/Toolbox/scripts"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
