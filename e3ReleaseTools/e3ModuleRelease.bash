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
#   date    : Friday, November  2 16:06:25 CET 2018
#   version : 0.0.7
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%y%m%d%H%M)"
#declare -gr SC_USER="$(whoami)"
declare -gr SC_HASH="$(git rev-parse --short HEAD)"

declare -gr DEFAULT_BRANCH="master"
declare -g  IsRequire=""
declare -g  IsBase=""
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

declare -g BRANCH=""

options=":b:h:y"
ANSWER="NO"

while getopts "${options}" opt; do
    case "${opt}" in
        b) BRANCH=${OPTARG} ;;

	y) ANSWER="YES" ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	h) usage ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit
	    ;;
    esac
done
shift $((OPTIND-1))


if [ -z "$BRANCH" ]; then
    #    printf ">> No BRANCH is defined, use the default one %s\n" "${DEFAULT_BRANCH}"
    BRANCH=${DEFAULT_BRANCH}
fi


print_options

MODULE_TOP=${PWD}

# Get all branches
git fetch origin

if [[ "$(basename ${MODULE_TOP})" =~ "e3-require" ]] ; then
    IsRequire="1";
elif [[ "$(basename ${MODULE_TOP})" =~ "e3-base" ]] ; then
    IsBase="1";
fi


## BE in ${BRANCH}
## However, we stop here if ${BRANCH} doesn't exist (Yes, master is always there)
if ! git checkout ${BRANCH}; then
    echo -e >&2 "\n>>\n  Please check ${PWD}.\n  It might not be a git repository or we cannot find the branch ${BRANCH}.";
    exit 1
fi

## STOP if any changes are exist in ${BRANCH}
any_changes=$(git status --porcelain --untracked-files=no)

if ! [ -z "${any_changes}" ] ; then
    die "ERROR : the ${BRANCH} branch was changed, please commit them first."
fi


## Assume three VERSIONs are defined one of both
## 
## E3_MODULE_VERSION:=        and   E3_MODULE_VERSION=
## EPICS_BASE:=               and   EPICS_BASE=
## E3_REQUIRE_VERSION:=       and   E3_REQUIRE_VERSION=

## If a repository is e3-base
## E3_BASE_VERSION:=          and   E3_BASE_VERSION=


if ! [ -z "${IsBase}" ]; then

    CONFIG_BASE=${MODULE_TOP}/configure/CONFIG_BASE

    if [[ $(checkIfFile "${CONFIG_BASE}") -eq "NON_EXIST" ]]; then
	die 1 "ERROR : we cannot find the file >>${CONFIG_BASE}<<";
    else
	base_version="$(read_file_get_string "${CONFIG_BASE}" "E3_BASE_VERSION:=")";
	if [ -z "${base_version}" ]; then
	    base_version="$(read_file_get_string  "${CONFIG_BASE}" "E3_BASE_VERSION=")";
	    if [ -z "${base_version}" ]; then
		die 1 "ERROR 2nd : we cannot read E3_BASE_VERSION properly, please check ${CONFIG_BASE}"
	    fi
	fi
    fi
    module_version=${base_version}
    require_version="NA"
    
else
    
    CONFIG_MODULE=${MODULE_TOP}/configure/CONFIG_MODULE
    RELEASE_BASE=${MODULE_TOP}/configure/RELEASE

    # RELEASE_BASE : EPICS_BASE
    if [[ $(checkIfFile "${RELEASE_BASE}") -eq "NON_EXIST" ]]; then
	die 1 "ERROR : we cannot find the file >>${RELEASE_BASE}<<";
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

    # RELEASE_BASE : E3_REQUIRE_VERSION
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

    # CONFIG_MODULE : E3_MODULE_VERSION
    if [ -z "${IsRequire}" ]; then
	if [[ $(checkIfFile "${CONFIG_MODULE}") -eq "NON_EXIST" ]]; then
	    printf "Maybe you are not in any module directory\n";
	    die 1 "ERROR : we cannot find the file >>${CONFIG_MODULE}<<";
	else
	    module_version="$(read_file_get_string   "${CONFIG_MODULE}" "E3_MODULE_VERSION:=")";
	    if [ -z "${module_version}" ]; then
		module_version="$(read_file_get_string   "${CONFIG_MODULE}" "E3_MODULE_VERSION=")";
		if [ -z "${module_version}" ]; then
		    die 1 "ERROR 2nd : we cannot read E3_MODULE_VERSION properly, please check ${CONFIG_MODULE}"
		fi
	    fi
	fi
    else
	# If a repository is e3-require, we use the require version as module version
	#
	module_version=${require_version}
    fi
fi #  if ! [ -z "${IsBase}" ]; then


printf "\n"
printf "E3 MODULE VERSION  : %34s\n" "${module_version}"
printf "EPICS BASE VERSION : %34s\n" "${base_version}"
printf "E3 REQUIRE VERSION : %34s\n" "${require_version}"


## MODULE  : 3.15.5-3.0.0/1.0.0-1810302033 : Branch 1.0.0
## REQUIRE : 3.15.5-3.0.0/3.0.0-1811010032 : Branch 3.0.0
## BASE    : 3.15.5-NA/3.15.5-1811010031   : Branch 3.15.5
## 
## use / in order to separate it from each other group
## $(dirname $MODULE_TAG_IN_BRANCH) returns base-req
## $(basename $MODULE_TAG_IN_BRANCH) returns module-date
##

MODULE_TAG_IN_BRANCH+=${base_version}
MODULE_TAG_IN_BRANCH+="-"
MODULE_TAG_IN_BRANCH+=${require_version}
MODULE_TAG_IN_BRANCH+="/"
MODULE_TAG_IN_BRANCH+=${module_version}
MODULE_TAG_IN_BRANCH+="-"
MODULE_TAG_IN_BRANCH+=${SC_LOGDATE}

MODULE_BRANCH_NAME=${module_version}

printf "\n"
printf "MODULE BRANCH      : %34s\n"   "$MODULE_BRANCH_NAME"
printf "MODULE TAG         : %34s\n\n" "$MODULE_TAG_IN_BRANCH"


case "$1" in

    release)
	if [ "$ANSWER" == "NO" ]; then
	    printf ">>\n";
	    printf "  Now you are entering the release e3 module...\n"
	    yes_or_no_to_go
	else
	    echo ""
	fi
	;;
    *)
	usage
	;;

esac



if [[ "$BRANCH" =~ "master" ]] ; then
    ### Check whether a branch with the module version or not
    branch_exist=$(git rev-parse --verify --quiet $MODULE_BRANCH_NAME)
    if [ -z "${branch_exist}" ] ; then
	# There is no branch, so create it
	# In this step, we don't have any conflict theoritically.
	#
	printf ">>\n";
	printf "  No Branch %s is found, creating ....\n" "${MODULE_BRANCH_NAME}"
	printf "\n";
	
	git checkout -b ${MODULE_BRANCH_NAME}
	git commit -m "adding ${MODULE_BRANCH_NAME}";
	# The first time, we also need to do git tag in that branch
	printf ">>\n";
	printf "  Creating .... the tag %s\n" "$MODULE_TAG_IN_BRANCH"
	git tag -a $MODULE_TAG_IN_BRANCH -m "add $MODULE_TAG_IN_BRANCH"

	printf ">>\n";
	if [ "$ANSWER" == "NO" ]; then
	    printf "  You can push these changes to the remote repository...\n"
	    read -p "  Do you want to continue (y/N)? " answer
	    case ${answer:0:1} in
		y|Y )
		    git push origin ${MODULE_BRANCH_NAME};
		    git push origin ${MODULE_TAG_IN_BRANCH};
		    ;;
		* )
		    printf ">>\n"
		    printf "  One can push these changes later through \n"
		    printf "  git push origin %s\n" "${MODULE_BRANCH_NAME}";
		    printf "  git push origin --tags\n";
   		    ;;
	    esac
	else
	    git push origin ${MODULE_BRANCH_NAME};
	    git push origin ${MODULE_TAG_IN_BRANCH};
	fi
	
	printf ">> \n"
	git checkout ${BRANCH}
	printf "\n";
	
    else
	printf ">>\n";
	printf "  The branch %s exists.\n" "${MODULE_BRANCH_NAME}"
	printf "  So, we end here.\n"
	printf ">>\n";
    fi
else
    ### Check the existent tag in the $BRANCH
    tag_list=$(git tag -l |grep "/${MODULE_BRANCH_NAME}-")

    let found=0;
    let not_found=0;
    for tag_a in  ${tag_list[@]}; do
	if [[ "$(dirname ${tag_a})" =~ "$(dirname $MODULE_TAG_IN_BRANCH)" ]] ; then
	    printf ">>> %d : %s is existent \n>>>     in the branch %s already.\n" "$i" "${tag_a}" "${MODULE_TAG_IN_BRANCH}"
	    ((++found))
	else
	    ((++not_found))
	fi
    done

    
    if [ "$found" -eq 0 ]; then
	# Nothing we find, so we create a tag for the current branch configuration.
	git tag -a $MODULE_TAG_IN_BRANCH -m "add $MODULE_TAG_IN_BRANCH"
	printf ">>\n";
	if [ "$ANSWER" == "NO" ]; then
	    printf "  You can push these changes to the remote repository...\n"
	    read -p "  Do you want to continue (y/N)? " answer
	    case ${answer:0:1} in
		y|Y )
		    git push origin ${MODULE_TAG_IN_BRANCH};
		    ;;
		* )
		    printf ">>\n"
		    printf "  One can push these changes later through \n"
		    printf "  git push origin --tags\n";
   		    ;;
	    esac
	else
	    git push origin ${MODULE_TAG_IN_BRANCH};
	fi
    else
	if [ "$found" -gt 1 ]; then
	    die 1 "STRANGE : We've found the same tag in $found times. Please check, there is something wrong!"
	fi
	printf ">>> We end the request procedure here.\n"
	printf "\n"

    fi
fi # [[ "$BRANCH" =~ "master" ]] ; then

exit
