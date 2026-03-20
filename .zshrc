eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd)"

export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

alias l='ls -Gal'

# Git
alias ga='git add .'
alias gs='git status'

gc() {
  git commit -m "$1"
}

