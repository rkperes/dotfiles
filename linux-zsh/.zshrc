# Based on https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52
autoload promptinit

setopt histignorealldups sharehistory

# Enable colors and change prompt:
autoload -U colors && colors

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/rkperes/.zshrc'

# Basic auto/tab complete:
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -u
_comp_options+=(globdots) # Include hidden files.

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

# source antidote (https://github.com/mattmc3/antidote)
if [ ! -f "$HOME/.antidote/antidote.zsh" ]; then
  ## install if not present
  echo 'installing antidote...'
  git clone --depth=1 https://github.com/mattmc3/antidote.git $HOME/.antidote
  echo 'antidote installed'
fi

source ${ZDOTDIR:-~}/.antidote/antidote.zsh
# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

#zsh-history-substring-search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

PROMPT="%B%{$fg[magenta]%}%1~ %(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})$%{$reset_color%}%b "

# -------------------------------------
# github ------------------------------
if command -v gh 1>/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi

# -------------------------------------
# python ------------------------------
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# -------------------------------------
# kubectl -----------------------------
function set-kubeconfig {
  # Sets the KUBECONFIG environment variable to a dynamic concatentation of everything
  # under ~/.kube/configs/*
  # Does NOT overwrite KUBECONFIG if the KUBECONFIG_MANUAL env var is set

  if [ -d ~/.kube/configs ]; then
    if [ -z "$KUBECONFIG_MANUAL" ]; then
      export KUBECONFIG=~/.kube/config$(find ~/.kube/configs -type f 2>/dev/null | xargs -I % echo -n ":%")
    fi
  fi
}
set-kubeconfig;
add-zsh-hook precmd set-kubeconfig
