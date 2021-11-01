# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/rkperes/.zshrc'

autoload -U colors && colors

autoload -Uz compinit
compinit
# End of lines added by compinstall

# PS1
setopt PROMPT_SUBST
ps1ret() {
    if [[ $? == 0 ]]; then
        echo -e '%F{green}$%f '
    else
        echo -e '%F{red}$%f '
    fi
}
PS1_DIR='%F{cyan}%2~%f '
PS1=${PS1_DIR}'$(ps1ret)'
# End of PS1

# aliases
alias g=git
alias ls='ls --color=auto -F'
alias l='ls'
alias ll='ls -lh'
