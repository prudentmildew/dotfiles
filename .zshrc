export SHELL_SESSIONS_DISABLE=1
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$HOME/bin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd)"

alias l='ls -Gal'
alias ga='git add .'
alias gl='git log'
alias gs='git status'
alias ..='cd ..'
alias ...='cd ../..'

#Commit staged changes, with message $1
gc() {
  git commit -m "$1"
}

#Delete local branch $1
gd() {
  git branch -d "$1"
}

#Push committed changes to remote
gp() {
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

#Create and checkout new branch $1
gb() {
  git checkout -b "$1"
}

#Switch to branch $1
go() {
  git checkout "$1"
}

#Super command: add + commit + push
gacp() {
  git add .
  git commit -m "$1"
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

