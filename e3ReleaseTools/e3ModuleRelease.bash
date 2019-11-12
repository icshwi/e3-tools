#!/bin/bash
#
#  Copyright (c) 2018 - 2019    Jeong Han Lee
#  Copyright (c) 2018 - 2019    European Spallation Source ERIC
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
#   date    : Monday, November 11 22:39:34 CET 2019
#   version : 0.1.2
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%y%m%d%H%M)"
declare -gr SC_HASH="$(git rev-parse --short HEAD)"

declare -gr DEFAULT_BRANCH="master"
declare -g  IsRequire=""
declare -g  IsBase=""
declare -g  VERSION_STRING=""
declare -g  MODULE_BRANCH=""
declare -g  MODULE_TAG_IN_BRANCH=""
declare -g  HEAD_HASH_TAG=""
declare -g  module_version=""
declare -g  require_version=""
declare -g  base_version=""
declare -g  base_path=""
declare -g  base_prefix="base-"
declare -ga tag_list=()


. ${SC_TOP}/.e3_module_release_functions

declare -g BRANCH=""
declare -g TARGET_SRC=""

options=":b:s:h:y"
ANSWER="NO"

while getopts "${options}" opt; do
    case "${opt}" in
        b)
	    BRANCH=${OPTARG};
	    TARGET_SRC=${BRANCH};
	   ;;
	s)
	    BRANCH=${DEFAULT_BRANCH};
	    TARGET_SRC=${OPTARG};
	    ;;
	y)
	    ANSWER="YES";
	   ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	h) usage
	   ;;
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
    TARGET_SRC=${BRANCH}
fi


print_options


MODULE_TOP=${PWD}

# Get all branches

printf ">> Stage 0 << \n";
printf "   Now we are fetching all into e3 module ...\n"
echo "    "
git fetch --all
printf "\n"




if [[ "$(basename ${MODULE_TOP})" =~ "e3-require" ]] ; then
    IsRequire="1";
elif [[ "$(basename ${MODULE_TOP})" =~ "e3-base" ]] ; then
    IsBase="1";
fi


## BE in ${TARGET_SRC}
## master, branch, or simulated master (any history log)
## However, we stop here if ${TARGET_SRC} doesn't exist (Yes, master is always there)
if ! git checkout ${TARGET_SRC}; then
    echo -e >&2 "\n>>\n  Please check ${PWD}.\n  It might not be a git repository or we cannot find the branch ${BRANCH}.";
    exit 1
fi

## git rev-parse HEAD will return "the current working branch or revision" hash information
## So, we are under "git checkout ${TARGET_SRC}

HEAD_HASH_TAG=$(git rev-parse --short HEAD)


## STOP if any changes are exist in ${BRANCH}
declare -a any_changes=()
any_changes=$(git status --porcelain --untracked-files=no)

print_options


if ! [ -z "${any_changes}" ] ; then
    if [[ "${#any_changes[@]}" == "1" ]]; then
	changed_name=$(echo "${any_changes[0]}"| cut -d" " -f3)
	CONFIG_MODULE=${MODULE_TOP}/configure/CONFIG_MODULE
	if [[ $(checkIfFile "${CONFIG_MODULE}") -eq "NON_EXIST" ]]; then
	    printf "Maybe you are not in any module directory\n";
	    die 1 "ERROR : we cannot find the file >>${CONFIG_MODULE}<<";
	else
	    module_name=$(read_version "${CONFIG_MODULE}" "E3_MODULE_SRC_PATH");
	fi
	if [[ "$changed_name" =~ "$module_name" ]] ; then
	    printf "\n>> Modified file name >>%s<< is the module src path >>%s<< \n" "$changed_name" "$module_name";
	    printf "   We can ignore this case.\n\n";
	else
	    die "ERROR : the ${BRANCH} branch was changed, but we don't know how to resolve it"
	fi

    else
	die "ERROR : the ${BRANCH} branch was changed, please check your branch first."
    fi
    
  
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
	base_version=$(read_version "${CONFIG_BASE}" "E3_BASE_VERSION")
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
	base_path=$(read_version "${RELEASE_BASE}" "EPICS_BASE")
	base_version=$(basename ${base_path})
	base_version=${base_version#${base_prefix}}
    fi

    # RELEASE_BASE : E3_REQUIRE_VERSION
    if [[ $(checkIfFile "${RELEASE_BASE}") -eq "NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the file >>${RELEASE_BASE}<<";
    else
	require_version=$(read_version "${RELEASE_BASE}" "E3_REQUIRE_VERSION");
    fi

    # CONFIG_MODULE : E3_MODULE_VERSION
    if [ -z "${IsRequire}" ]; then
	if [[ $(checkIfFile "${CONFIG_MODULE}") -eq "NON_EXIST" ]]; then
	    printf "Maybe you are not in any module directory\n";
	    die 1 "ERROR : we cannot find the file >>${CONFIG_MODULE}<<";
	else
	    module_version=$(read_version "${CONFIG_MODULE}" "E3_MODULE_VERSION");
	fi
    else
	# If a repository is e3-require, we use the require version as module version
	#
	module_version=${require_version}
    fi
fi #  if ! [ -z "${IsBase}" ]; then


printf "\n"
printf "E3 MODULE VERSION  : %38s\n" "${module_version}"
printf "EPICS BASE VERSION : %38s\n" "${base_version}"
printf "E3 REQUIRE VERSION : %38s\n" "${require_version}"


## MODULE  : 3.15.5-3.0.0/1.0.0-1810302033 : Branch 1.0.0
## REQUIRE : 3.15.5-3.0.0/3.0.0-1811010032 : Branch 3.0.0
## BASE    : 3.15.5-NA/3.15.5-1811010031   : Branch 3.15.5
## 
## use / in order to separate it from each other group
## $(dirname $MODULE_TAG_IN_BRANCH) returns base-req
## $(basename $MODULE_TAG_IN_BRANCH) returns module-date
##


MODULE_BRANCH_NAME=R-${module_version}

MODULE_TAG_IN_BRANCH+=${base_version}
MODULE_TAG_IN_BRANCH+="-"
MODULE_TAG_IN_BRANCH+=${require_version}
MODULE_TAG_IN_BRANCH+="/"
MODULE_TAG_IN_BRANCH+=${MODULE_BRANCH_NAME}
MODULE_TAG_IN_BRANCH+="-"
MODULE_TAG_IN_BRANCH+=${HEAD_HASH_TAG}
MODULE_TAG_IN_BRANCH+="-"
MODULE_TAG_IN_BRANCH+=${SC_LOGDATE}

printf "\n"
printf "MODULE BRANCH      : %38s\n"   "$MODULE_BRANCH_NAME"
printf "MODULE TAG         : %38s\n\n" "$MODULE_TAG_IN_BRANCH"


case "$1" in

    release)
	if [ "$ANSWER" == "NO" ]; then
	    printf ">> Stage 1 << \n";
	    printf "   Now you are entering the release e3 module...\n"
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
    remote_branch_exist=$(git branch -r -a |grep "remotes/origin/${MODULE_BRANCH_NAME}")
    local_branch_exist=$(git branch -r -a |grep "${MODULE_BRANCH_NAME}")

    
    if [ -z "${remote_branch_exist}" ] && [ -z "${local_branch_exist}" ]; then
	# There is no branch, so create it
	# In this step, we don't have any conflict theoritically.
	#
	printf ">> Stage 2\n";
	printf "   No Branch %s is found, creating ....\n" "${MODULE_BRANCH_NAME}"
	printf "\n";

	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go
	fi


	git branch "${MODULE_BRANCH_NAME}"  || die 1 "STRANGE : We cannot create ${MODULE_BRANCH_NAME}. Please check it"
	git checkout ${MODULE_BRANCH_NAME}  || die 1 "STRANGE : We cannot swtch into branch ${MODULE_BRANCH_NAME}. Please check it"
	git commit -m "adding ${MODULE_BRANCH_NAME}";
	# The first time, we also need to do git tag in that branch
	printf ">> Stage 3\n";
	printf "  Creating .... the tag %s\n" "$MODULE_TAG_IN_BRANCH"
	git tag -a $MODULE_TAG_IN_BRANCH -m "add $MODULE_TAG_IN_BRANCH"

	printf ">>\n";
	if [ "$ANSWER" == "NO" ]; then
	    printf "  You can push these changes to the remote repository...\n"
	    read -p "  Do you want to continue (y/N)? " answer
	    case ${answer:0:1} in
		y|Y )
		    git push origin ${MODULE_BRANCH_NAME}    || die 1 "Error : We cannot push origin ${MODULE_BRANCH_NAME}"
		    git push origin ${MODULE_TAG_IN_BRANCH}  || die 1 "Error : We cannot push origin ${MODULE_TAG_IN_BRANCH}"
		    ;;
		* )
		    printf ">>\n"
		    printf "  One can push these changes later through \n"
		    printf "  git push origin %s\n" "${MODULE_BRANCH_NAME}";
		    printf "  git push origin %s\n" "${MODULE_TAG_IN_BRANCH}";
   		    ;;
	    esac
	else
	    git push origin ${MODULE_BRANCH_NAME}   || die 1 "Error : We cannot push origin ${MODULE_BRANCH_NAME}"
	    git push origin ${MODULE_TAG_IN_BRANCH} || die 1 "Error : We cannot push origin ${MODULE_TAG_IN_BRANCH}"
	fi
	
	printf ">> \n"
	git checkout  ${TARGET_SRC} || die 1 "Error : We cannot checkout ${TARGET_SRC}\n";
	
    else
	
	printf ">> Stage 2\n";
	if ! [ -z "${remote_branch_exist}" ]; then
	    printf "   The branch %s is found remotely.\n" "${MODULE_BRANCH_NAME}"
	fi
	if ! [ -z "${local_branch_exist}" ]; then
	    printf "   The branch %s is found locally.\n" "${MODULE_BRANCH_NAME}"
	fi
	# Get the branch hash id to compare the master branch
	# with the asumption that that branch is in origin
	branch_hash_tag=$(git rev-parse --short origin/${MODULE_BRANCH_NAME})

	printf "\n";
	if [ "$branch_hash_tag" = "${HEAD_HASH_TAG}" ]; then

	    printf "  Master %s is the same as Branch %s %s\n" "${HEAD_HASH_TAG}" "${MODULE_BRANCH_NAME}" "$branch_hash_tag"
	    printf "  So, we end here.\n"
	    printf ">>\n";
	else

	    printf "  Master %s is not the same as Branch %s %s\n" "${HEAD_HASH_TAG}" "${MODULE_BRANCH_NAME}" "$branch_hash_tag"
	    printf "  Now we are merging from %s to %s ....\n" "${TARGET_SRC}" "${MODULE_BRANCH_NAME}"

	    if [ "$ANSWER" == "NO" ]; then
		yes_or_no_to_go
	    fi

	    # Here TARGET_SRC is master branch
	    printf ">>> 0 : git checkout %s\n", "${TARGET_SRC}" 
	    git checkout "${TARGET_SRC}"               || die 1 "Error : We cannot checkout ${TARGET_SRC}\n";
	    git pull --rebase origin "${TARGET_SRC}"   || die 1 "Error : We cannot pull --rebase origin  ${TARGET_SRC}\n";
	    # We merge all changes into ${MODULE_BRANCH_NAME}, because the all files within master at this moment
	    # are "release" one. It works both with three golden versions within e3.
	    git merge -s ours "origin/${MODULE_BRANCH_NAME}"  || die 1 "Error : We cannot git merge -s ours ${MODULE_BRANCH_NAME}\n";
	    git checkout "${MODULE_BRANCH_NAME}"       || die 1 "Error : We cannot checkout ${MODULE_BRANCH_NAME}\n";
	    git merge "${TARGET_SRC}"                  || die 1 "Error : We cannot merge ${TARGET_SRC}\n";

	    
	    printf " Now you are committing and creating a tag ....\n";
	    if [ "$ANSWER" == "NO" ]; then
		yes_or_no_to_go
	    fi
	    
	    git commit -m "merging ours from ${TARGET_SRC} to ${MODULE_BRANCH_NAME}";
	    
	    git tag -a $MODULE_TAG_IN_BRANCH -m "add $MODULE_TAG_IN_BRANCH"

	    	printf ">>\n";
		if [ "$ANSWER" == "NO" ]; then
		    printf "  You can push these changes to the remote repository...\n"
		    read -p "  Do you want to continue (y/N)? " answer
		    case ${answer:0:1} in
			y|Y )
			    git push origin ${MODULE_BRANCH_NAME}   || die 1 "Error : We cannot push origin ${MODULE_BRANCH_NAME}"
			    git push origin ${MODULE_TAG_IN_BRANCH} || die 1 "Error : We cannot push origin ${MODULE_TAG_IN_BRANCH}"
			    ;;
			* )
			    printf ">>\n"
			    printf "  One can push these changes later through \n"
			    printf "  git push origin %s\n" "${MODULE_BRANCH_NAME}";
			    printf "  git push origin %s\n" "${MODULE_TAG_IN_BRANCH}";
   			    ;;
		    esac
		else
		    git push origin ${MODULE_BRANCH_NAME}   || die 1 "Error : We cannot push origin ${MODULE_BRANCH_NAME}"
		    git push origin ${MODULE_TAG_IN_BRANCH} || die 1 "Error : We cannot push origin ${MODULE_TAG_IN_BRANCH}"
		fi
		
	    
	fi
    fi
    # Return to master
    git checkout ${BRANCH}
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
		    printf "  git push origin %s\n" "${MODULE_TAG_IN_BRANCH}";
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


	    # file=$(mktemp -q) && {
	    # 	git show ${MODULE_BRANCH_NAME}:configure/RELEASE > "$file"
	    # 	branch_base_path=$(read_version "${file}" "EPICS_BASE")
	    # 	branch_base_version=$(basename ${branch_base_path})
	    # 	branch_base_version=${branch_base_version#${base_prefix}}
	    # 	rm "$file"
	    # }
	    # file=$(mktemp -q) && {
	    # 	git show ${MODULE_BRANCH_NAME}:configure/RELEASE > "$file"
	    # 	branch_require_version=$(read_version "${file}" "E3_REQUIRE_VERSION")
	    # 	rm "$file"
	    # }
	    
