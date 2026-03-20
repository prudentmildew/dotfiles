#!/bin/zsh

DOTFILES="$HOME/.dotfiles"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"

  if [ ! -e "$src" ]; then
    echo "SKIP  $src (not found)"
    return
  fi

  if [ -L "$dst" ]; then
    echo "OK    $dst (already linked)"
    return
  fi

  if [ -e "$dst" ]; then
    echo "BACK  $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  ln -s "$src" "$dst"
  echo "LINK  $dst -> $src"
}

link ".zshrc"        ".zshrc"
link ".gitconfig"    ".gitconfig"
link ".config"       ".config"

echo "\nDone."
