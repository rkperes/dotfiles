#!/bin/sh

mkdir -p "$HOME/.zsh"
git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.zsh/spaceship"

mkdir -p $HOME/.config
cp -r .* $HOME/
