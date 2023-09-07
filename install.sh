#!/bin/bash

set -e

#------------------------------------------------------------------------------#
# Download
#------------------------------------------------------------------------------#
dir=.dotfiles
echo "> Downloading dotfiles to $dir..."
git clone --quiet --bare git@github.com:rkperes/dotfiles.git --branch "${DOTFILES_BRANCH:-main}" "$HOME/$dir"
cmd() { git --git-dir="$HOME/$dir" --work-tree="$HOME" "$@"; }

#------------------------------------------------------------------------------#
# Backup already existing dotfiles
#------------------------------------------------------------------------------#
files=($(cmd ls-tree -r HEAD | awk '{print $NF}'))
bkp=.dotfiles.backup
for f in "${files[@]}"; do
  # File at root ==> back up file
  if [[ $(basename "$f") = "$f" ]]; then
    [[ -f "$HOME/$f" ]] && mkdir -p "$HOME/$bkp" && mv "$HOME/$f" "$HOME/$bkp" && echo "> Backing up: $f ==> $bkp/$f"
  # File in nested directory ==> back up outermost directory
  else
    d=${f%%/*}
    if [[ -d "$HOME/$d" ]]; then
      [[ -d "$HOME/$bkp/$d" ]] && rm -rf "$HOME/$bkp/$d"
      mkdir -p "$HOME/$bkp" && mv "$HOME/$d" "$HOME/$bkp" && echo "> Backing up: $d/ ==> $bkp/$d/"
    fi
  fi
done

#------------------------------------------------------------------------------#
# Install
#------------------------------------------------------------------------------#
cmd checkout
cmd submodule --quiet init
cmd submodule --quiet update
cmd config status.showUntrackedFiles no
echo "> Success! The following dotfiles have been installed to $HOME:"
printf '    %s\n' "${files[@]}"
