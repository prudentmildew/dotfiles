# Interactive-shell setup. Environment and PATH live in .zprofile.

autoload -Uz compinit && compinit

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(starship init zsh)"

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

#Push current branch to origin
gp() {
  git push origin HEAD
}

#Create and checkout new branch $1
gb() {
  git checkout -b "$1"
}

#Super command: add + commit + push (stops at the first failure)
gacp() {
  git add . && git commit -m "$1" && git push origin HEAD
}
