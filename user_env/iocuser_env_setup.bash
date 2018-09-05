#!/bin/bash
#
#  Copyright (c) 2016 - Present Jeong Han Lee
#  Copyright (c) 2016           European Spallation Source ERIC

#  This shell script is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.0.4

set -efo pipefail

# 
# PREFIX : SC_, so declare -p can show them in a place
# 
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_IOCUSER="$(whoami)"


declare -gr GIT_PROMPT="git-prompt.sh";
declare -gr GIT_COMPET="git-completion.bash";
declare -gr EMACS_EPICS_MODE="epics-mode.el";
declare -gr EMACS_D=".emacs.d";

declare -gr SSH_D=".ssh";
declare -gr SSH_CONF_FILE="config";


# Generic : Redefine pushd and popd to reduce their output messages
# 
#function pushd() { builtin pushd "$@" > /dev/null; }
#function popd()  { builtin popd  "$@" > /dev/null; }


function ini_func() { sleep 0.5; printf "\n>>>> You are entering in : %s\n" "${1}"; }
function end_func() { sleep 0.5; printf "\n<<<< You are leaving from %s\n" "${1}"; }


function make_link() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local target_name=$1;
    printf "Creating Symbolic link of %s to %s" "${target_name}" "${HOME}/.${target_name}" ;
    ln -s ${SC_TOP}/.${target_name} ${HOME}/.${target_name};

    end_func ${func_name};  
}

function make_install() {
    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local target_name=$1;
    printf "Hard copy %s in %s" "${target_name}" "${HOME}/.${target_name}" ;
    scp -r ${SC_TOP}/.${target_name} ${HOME}/.${target_name};
    end_func ${func_name};  
}

function make_epics_mode() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    printf "Setup the EPICS mode for emacs\n";
    printf "Create Sym link %s" "${HOME}/${EMACS_D}/${EMACS_EPICS_MODE}" ;

    mkdir -p ${HOME}/${EMACS_D};
    ln -sf  ${SC_TOP}/${EMACS_EPICS_MODE} ${HOME}/${EMACS_D}/${EMACS_EPICS_MODE};

    end_func ${func_name}; 
}



function make_install_epics_mode() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    printf "Setup the EPICS mode for emacs\n";
    printf "Hard copy  %s" "${HOME}/${EMACS_D}/${EMACS_EPICS_MODE}" ;

    mkdir -p ${HOME}/${EMACS_D};
    scp -r  ${SC_TOP}/${EMACS_EPICS_MODE} ${HOME}/${EMACS_D}/;

    end_func ${func_name}; 
}


function make_ssh_mode() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    printf "Setup the SSH configuration\n";
    printf "Create Sym link %s" "${HOME}/${SSH_D}/${SSH_CONF_FILE}" ;

    mkdir -p ${HOME}/${SSH_D};
    chmod 600 ${HOME}/${SSH_D}/${SSH_CONF_FILE};
    ln -sf  ${SC_TOP}/${SSH_CONF_FILE} ${HOME}/${SSH_D}/${SSH_CONF_FILE};

    end_func ${func_name}; 
}


function make_install_ssh_mode() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    printf "Setup the SSH configuration\n";
    printf "Create Sym link %s" "${HOME}/${SSH_D}/${SSH_CONF_FILE}" ;

    mkdir -p ${HOME}/${SSH_D};
    install -m 600  ${SC_TOP}/${SSH_CONF_FILE} ${HOME}/${SSH_D}/${SSH_CONF_FILE};

    end_func ${func_name}; 
}



function get_gits() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local web_site="https://raw.githubusercontent.com/git/git/master/contrib/completion"
    local git_prompt="${HOME}/.${GIT_PROMPT}";
    local git_completion="${HOME}/.${GIT_COMPET}";

    printf "Dowloading %s %s" "${GIT_PROMPT}" "${GIT_COMPET}";

    curl -L \
	${web_site}/${GIT_PROMPT} -o ${git_prompt} \
	${web_site}/${GIT_COMPET} -o ${git_completion};
    
    end_func ${func_name};  
}


function clean_epics_mode() {
    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local epicsmode=${HOME}/${EMACS_D}/${EMACS_EPICS_MODE};

    if [[ -a ${epicsmode} ]]; then
	printf "Cleaning %s" "${epicsmode}";
	rm -f ${epicsmode};
    fi
    end_func ${func_name};  
}    



function clean_cfg() {
    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local target_name=${HOME}/.${1};

    printf "Cleaning cfg : %s" "${target_name}";
    rm -f ${target_name};

    end_func ${func_name};  
}




function clean_ssh_mode() {
    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local local_mode=${HOME}/${SSH_D}/${SSH_CONF_FILE};
   
    if [[ -a ${local_mode} ]]; then
	printf "Cleaning %s" "${loca_mode}";
	rm -f ${local_mode};
    fi
    end_func ${func_name};  
}    


function clean_gits() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local git_prompt="${HOME}/.${GIT_PROMPT}";
    local git_completion="${HOME}/.${GIT_COMPET}";

    if [[ -a ${git_prompt}  ]]; then
	printf "Cleaing gits : %s" "${git_prompt}";
	rm -f ${git_prompt};
    fi	

    if [[ -a ${git_completion} ]]; then
	printf "Cleaing gits : %s" "${git_completion}";
	rm -f ${git_completion};
    fi	

    end_func ${func_name};  
}

TARGET_LIST="emacs screenrc bashrc bash_aliases gitconfig gitignore"


#echo $CDIR



# What should we do?
DO="$1"

case "$DO" in

    install)
	make_install_epics_mode
	make_install_ssh_mode
	get_gits
	
	for d in $TARGET_LIST
	do
	    make_install $d
	done

	
        ;;
    link)
	make_epics_mode
	make_ssh_mode
	get_gits
	
	for d in $TARGET_LIST
	do
	    make_link $d
	done
	;;
    
    clean)
	clean_epics_mode
	clean_ssh_mode
	clean_gits
	for d in $TARGET_LIST
	do
	    clean_cfg $d
	done
	;;
    *)
	echo "">&2
        echo "usage: $0 <command>" >&2
        echo >&2
        echo "  commands: " >&2
	echo ""
        echo "          install : install all real files ">&2
        echo ""
	echo "          link    : install all symbolic links">&2
	echo ""
	echo "          clean   : clean all existent links and files ">&2
        echo ""
        echo >&2
	exit 0
        ;;
esac

