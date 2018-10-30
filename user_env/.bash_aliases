# This is the unofficial configuration file for iocuser of ICS at ESS
#
#  Author  : Jeong Han Lee
#  email   : han.lee@esss.se
#  Date    : 2016-10-25
#  version : 0.0.1


# if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
# fi

alias vi='vim'
#alias du='du -h'
#alias df='df -kh'

#-------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------
# Add colors for filetype and  human-readable sizes by default on 'ls':
#alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then    
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


#alias mv='mv -i'
alias cp='cp -i'

alias watchtime='watch --interval 1 date'
alias p5="ps -eo user,pcpu,pid,cmd | sort -r -k2 | head -6"


# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

#alias E3='source /epics/modules/require/2.5.4/bin/setE3Env.bash'
#export EPICS_CA_AUTO_ADDR_LIST=yes


goE3() {

       E3_PATH1=${HOME}/e3
       E3_PATH2=${HOME}/ics_gitsrc/e3
       E3_PATH3=/epics/base-3.15.5/require/3.0.0/bin

       if [ -d "$E3_PATH1" ]; then
       	  . ${E3_PATH1}/tools/setenv
       elif [ -d "$E3_PATH2" ]; then
          . ${E3_PATH2}/tools/setenv
       elif [ -d "$E3_PATH3" ]; then
          . ${E3_PATH3}/setE3Env.bash
       else
          echo "We couldn't find E3 source path now."
	  echo "please go your e3 path and "
	  echo "source tools/setenv"
       fi
}

