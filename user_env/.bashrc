# This is the unofficial configuration file for iocuser of ICS at ESS
#
#  Author  : Jeong Han Lee
#  email   : han.lee@esss.se
#  Date    : 2016-10-25
#  version : 0.0.1

if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# slightly modified for git-prompt.sh 
source ~/.git-prompt.sh
source ~/.git-completion.bash


case "$TERM" in
xterm*|rxvt*)
    PS1='\u@\h: \W$(__git_ps1 " (%s)")\$ '
    ;;
*)
    ;;
esac


if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
