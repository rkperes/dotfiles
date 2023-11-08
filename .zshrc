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

#PROMPT="%B%{$fg[magenta]%}%1~ %(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})$%{$reset_color%}%b "

function isMac() {
  [ "$(uname)" = "Darwin" ]
}

function isBrew() {
  isMac && type "brew" > /dev/null
}

if ! type "starship" > /dev/null; then
    if isBrew; then
        echo "brew install starship"
        brew install starship
    else
        echo "install starship"
        curl -sS https://starship.rs/install.sh | sh
    fi
fi
# requires NerdFont
eval "$(starship init zsh)"

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
if whence dircolors >/dev/null; then
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  alias ls='ls --color'
else
  export CLICOLOR=1
  zstyle ':completion:*:default' list-colors ''
fi
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
if isBrew; then
    if [ ! -f $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh ]; then
        echo "brew install antidote"
        brew install antidote
    fi
    source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
else
    if [ ! -f ${ZDOTDIR:-~}/.antidote/antidote.zsh ]; then
        echo "clone antidote"
        git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
    fi

    source ${ZDOTDIR:-~}/.antidote/antidote.zsh
fi
# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

#zsh-history-substring-search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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

# -------------------------------------
# nvim --------------------------------

# install locally (overrides) if nvim <= v0.8
if [ $(nvim -v 2>&1 | sed -n '/^NVIM v0\.[0-8]/p' 2>&1 | wc -l) -eq 0 ]; then 
  if isBrew; then
    echo "brew install nvim"
    brew install nvim
  else
    echo "install nvim-linux64"
  (
    mkdir -p ~/tmp && cd ~/tmp && \
    wget "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz" && \
    tar xzf nvim-linux64.tar.gz && \
    mkdir -p ~/.local && mv nvim-linux64 ~/.local/nvim && \
    mkdir -p ~/.local/bin && cd ~/.local/bin && ln -s nvim $HOME/.local/nvim/bin/nvim
  )
  fi
fi

