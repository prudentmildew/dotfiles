export SHELL_SESSIONS_DISABLE=1
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd)"

alias l='ls -Gal'
alias ga='git add .'
alias gl='git log'
alias gs='git status'

gc() {
  git commit -m "$1"
}

gp() {
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

gb() {
  git checkout -b "$1"
}

go() {
  git checkout "$1"
}

