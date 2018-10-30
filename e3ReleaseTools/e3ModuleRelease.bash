#!/bin/bash
#
#  Copyright (c) 2018 - Present Jeong Han Lee
#  Copyright (c) 2018 - Present European Spallation Source ERIC
#
#  The program is free software: you can redistribute
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
#
#   author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : Friday, October 26 22:21:12 CEST 2018
#   version : 0.0.1

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%y%m%d%H%M)"
declare -gr SC_USER="$(whoami)"
declare -gr SC_HASH="$(git rev-parse --short HEAD)"


declare -g  VERSION_STRING=""
declare -g  MODULE_BRANCH=""
declare -g  MODULE_TAG_IN_BRANCH=""
declare -g  module_version=""
declare -g  require_version=""
declare -g  base_version=""
declare -g  base_path=""
declare -g  base_prefix="base-"
declare -ga tag_list=()


. ${SC_TOP}/.e3_module_release_functions



function usage
{
    {
	echo "";
	echo "Usage    : $0  in e3 module directory" ;
	echo "";
	echo ""
	
    } 1>&2;
    exit 1; 
}


MODULE_TOP=${PWD}

CONFIG_MODULE=${MODULE_TOP}/configure/CONFIG_MODULE
RELEASE_BASE=${MODULE_TOP}/configure/RELEASE


###  MUST be in master
git checkout master

### MUST stop if any changes are exist in the master

any_changes=$(git status --porcelain --untracked-files=no)

if ! [ -z "${any_changes}" ] ; then
    die "ERROR : the master branch was changed, please commit them first."
fi



## Assume three VERSIONs are defined one of both
## 
## E3_MODULE_VERSION:=        and   E3_MODULE_VERSION=
## EPICS_BASE:=               and   EPICS_BASE=
## E3_REQUIRE_VERSION:=       and   E3_REQUIRE_VERSION=
if [[ $(checkIfFile "${CONFIG_MODULE}") -eq "NON_EXIST" ]]; then
    die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the file >>${CONFIG_MODULE}<<";
else
    module_version="$(read_file_get_string   "${CONFIG_MODULE}" "E3_MODULE_VERSION:=")";
    if [ -z "${module_version}" ]; then
	module_version="$(read_file_get_string   "${CONFIG_MODULE}" "E3_MODULE_VERSION=")";
	if [ -z "${module_version}" ]; then
	    die 1 "ERROR 2nd : we cannot read E3_MODULE_VERSION properly, please check ${CONFIG_MODULE}"
	fi
    fi
	   
fi

printf "\nE3 MODULE VERSION  : %14s\n" "${module_version}"

if [[ $(checkIfFile "${RELEASE_BASE}") -eq "NON_EXIST" ]]; then
    die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the file >>${RELEASE_BASE}<<";
else
    base_path="$(read_file_get_string  "${RELEASE_BASE}" "EPICS_BASE:=")";
    
    if [ -z "${base_path}" ]; then
	base_path="$(read_file_get_string  "${RELEASE_BASE}" "EPICS_BASE=")";
	if [ -z "${base_path}" ]; then
	    die 1 "ERROR 2nd : we cannot read EPICS_BASE properly, please check ${RELEASE_BASE}"
	fi
    fi
    # Remove all except base-N.N.N.N, and select after $base_prefix (base-)
    # 
    base_version=$(basename ${base_path})
    base_version=${base_version#${base_prefix}}

fi

printf "EPICS BASE VERSION : %14s\n" "${base_version}"

if [[ $(checkIfFile "${RELEASE_BASE}") -eq "NON_EXIST" ]]; then
    die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the file >>${RELEASE_BASE}<<";
else
    require_version="$(read_file_get_string "${RELEASE_BASE}" "E3_REQUIRE_VERSION:=")";
    if [ -z "${require_version}" ]; then
     	require_version="$(read_file_get_string "${RELEASE_BASE}" "E3_REQUIRE_VERSION=")";
	if [ -z "${require_version}" ]; then
     	    die 1 "ERROR 2nd : we cannot read E3_REQUIRE_VERSION properly, please check ${RELEASE_BASE}"
     	fi
    fi
    
	   
fi

printf "E3 REQUIRE VERSION : %14s\n" "${require_version}"

# 3.15.5-3.0.0/1.0.0-1810302033
# use / in order to separate it from each other group
# $(dirname $MODULE_TAG_IN_BRANCH) returns base-req
# $(basename $MODULE_TAG_IN_BRANCH) returns module-date
MODULE_TAG_IN_BRANCH+=${base_version}
MODULE_TAG_IN_BRANCH+="-"
MODULE_TAG_IN_BRANCH+=${require_version}
MODULE_TAG_IN_BRANCH+="/"
MODULE_TAG_IN_BRANCH+=${module_version}
MODULE_TAG_IN_BRANCH+="-"
### YYMMDD-HHMM
MODULE_TAG_IN_BRANCH+=${SC_LOGDATE}

MODULE_BRANCH_NAME=${module_version}

printf "\n"
printf "MODULE BRANCH      : %34s\n" "$MODULE_BRANCH_NAME"
printf "MODULE TAG         : %34s\n\n" "$MODULE_TAG_IN_BRANCH"


### Check whether a branch with the module version or not
branch_exist=$(git rev-parse --verify --quiet $MODULE_BRANCH_NAME)
    
if [ -z "${branch_exist}" ] ; then
    # There is no branch, so create it
    # In this step, we don't have any conflict theoritically.
    #
    git checkout -b ${MODULE_BRANCH_NAME}
    git commit -m "adding ${MODULE_BRANCH_NAME}";
    git push origin ${MODULE_BRANCH_NAME};
    # The first time, we also need to do git tag in that branch
    git tag -a $MODULE_TAG_IN_BRANCH -m "add $MODULE_TAG_IN_BRANCH"
    git push origin --tags
 
else
    printf "We have %s at %s\n" "${MODULE_BRANCH_NAME}" "${branch_exist}";
    printf "\nSummon all tag information within %s\n" "${MODULE_BRANCH_NAME}"
    
    tag_list=$(git tag -l |grep "/${MODULE_BRANCH_NAME}-")

    let found=0;
    let not_found=0;
    for tag_a in  ${tag_list[@]}; do
	if [[ "$(dirname ${tag_a})" =~ "$(dirname $MODULE_TAG_IN_BRANCH)" ]] ; then
	    printf ">>> %d : %s is existent \n>>>     in the branch %s already.\n" $i "${tag_a}" "${MODULE_TAG_IN_BRANCH}"
	    ((++found))
	else
	    ((++not_found))
	fi
    done

    
    if [ "$found" -eq 0 ]; then
	# Nothing we find, so we create it
	git checkout ${MODULE_BRANCH_NAME}
	git fetch origin
	git merge origin/master
	
	printf ">>> Merging from Master into %s\n" "$MODULE_TAG_IN_BRANCH"
	printf ">>> After no conflict by this merging, please run the following commands\n"
	printf ">>>\n" 
	printf " git push -u origin %s\n" "${MODULE_BRANCH_NAME}"
	printf " git tag -a %s -m \"add %s\"\n" "$MODULE_TAG_IN_BRANCH" "$MODULE_TAG_IN_BRANCH" 
	printf " git push origin --tag\n"
	printf ">>> \n";
	printf ">>> We end the request procedure here.\n"
	printf "\n"
	exit; 
    else
	if [ "$found" -gt 1 ]; then
	     die 1 "STRANGE : We've found the same tag in $found times. Please check, there is something wrong!"
	fi
	printf ">>> We end the request procedure here.\n"
	printf "\n"

    fi
    
fi


printf ">> Switching master ...\n";
git checkout master
printf "\n"

exit
