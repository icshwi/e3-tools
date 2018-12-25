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
#   date    : Tuesday, December 25 23:58:25 CET 2018
#   version : 0.7.4

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_USER="$(whoami)"
declare -gr SC_HASH="$(git rev-parse --short HEAD)"

declare -g  LOG=".MODULE_LOG"
declare -g  UPDATE_LOG=".UPDATE_MODULE_LOG";

declare -g  E3_MODULE_DEST=""

declare -gr _E3_EPICS_PATH=/epics
declare -gr _E3_BASE_VERSION=3.15.5
declare -gr _E3_REQUIRE_NAME=require
declare -gr _E3_REQUIRE_VERSION=3.0.4
declare -gr _EPICS_BASE=${_E3_EPICS_PATH}/base-${_E3_BASE_VERSION}

declare -g  _EPICS_MODULE_NAME=""
declare -g  _E3_MODULE_SRC_PATH=""
declare -g  _E3_MOD_NAME=""
declare -g  _E3_TGT_URL_FULL=""
declare -g  _E3_MODULE_GITURL_FULL=""


. ${SC_TOP}/.e3_template_funcs.cfg


targetpath=""
remotesrc=""
localsrc=""
siteApps=""
siteMods=""
updateSource=""

function usage
{
    {
	echo "";
	echo "Usage    : $0 [-m <module_configuraton_file>] [-d <module_destination_path>]" ;
	echo "";
	echo "               -m : a module configuration file, please check ${SC_TOP}/modules_conf path"
	echo "               -d : a destination, optional, Default \$PWD : ${SC_TOP} "
	echo "               -t : an existent module path for updating configuration files";
	echo "";
	echo "Examples in modules_conf  : ";
	echo "";
	echo " bash $0 -m  snmp3.conf"
	echo " bash $0 -m  snmp3.conf -d ~/testing"
	echo "";
	echo "         : $0 [-u <existent_module_path>] {-y} ";
	echo "               -u : an existent module path for updating configuration files";
	echo "               -y : siteMods (Site Modules)"
	echo "                  : without -y, Default is siteApps (Site Application)";
	echo "";
	echo "";
	echo ""
	
    } 1>&2;
    exit 1; 
}


function warning_path
{
    local path="$1"; shift;
    {
	printf ">>\n";
	printf "  One should not run $0 with %s.\n" "$path"
	printf "  \"$0\" is designed for e3 modules and its applications. \n";
	printf ">>\n";
    } 1>&2;
    exit 1; 
}



function help
{
    {
	printf "\n\n";
        printf ">>>> Skipping add the remote repository url. \n";
	printf "     And skipping push the ${_E3_MOD_NAME} to the remote also.\n";
	printf "\n";
	printf "In case, one would like to push this e3 module to git repositories,\n"
	printf "Please use the following commands within ${_E3_MOD_NAME}/ :\n"
	printf "\n";
	printf "   * git remote add origin ${_E3_TGT_URL_FULL}\n";
	printf "   * git commit -m \"First commit\"\n";
	printf "   * git push -u origin master\n";
    } 1>&2;
}


function help_update
{
    {
	printf "\n\n";
        printf ">>>> This script cannot cover 100 percent senario of your repository. \n";
	printf "     It would be better to check which files are updated. \n";
	printf "\n";
	printf "     The following commands are useful.\n"
	printf "\n";
	printf "   * git diff\n";
	printf "   * git add -A\n";
	printf "   * git checkout\n";
    } 1>&2;
}


function help_modulename
{
    local name="$1"; shift;
    {
	printf ">>\n";
	printf "  We've detected that your module name %s is not acceptable.\n" "$name"
	printf "  Please use letters (upper and lower case) and digits.\n"
	printf "  The underscore character _ is also permitted.\n" 
	printf ">>\n";
    } 1>&2;
    exit 1; 
}

function module_info
{
    local length=;
    
    printf "\n>>\n"
    if ! [ -z "${localsrc}" ]; then
	printf ">> Your sources are located in %s.\n"  "${_E3_MOD_NAME}"
    else
	printf ">> Your sources are located in %s.\n" "${epics_mod_url}"
	printf ">> git submodule will be used.\n"
    fi
    printf ">> \n";
    printf "EPICS_MODULE_NAME  : %${length}s\n" "${_EPICS_MODULE_NAME}"
    printf "E3_MODULE_SRC_PATH : %${length}s\n" "${_E3_MODULE_SRC_PATH}"
    if ! [ -z "${remotesrc}" ]; then
	printf "EPICS_MODULE_URL   : %${length}s\n" "${epics_mod_url}"
    fi
    printf "E3_TARGET_URL      : %${length}s\n" "${e3_target_url}"

    printf ">> \n";
    printf "e3 module name     : %${length}s\n" "${_E3_MOD_NAME}"
    if ! [ -z "${remotesrc}" ]; then
	printf "e3 module url full : %${length}s\n" "${_E3_MODULE_GITURL_FULL}"
    fi
    printf "e3 target url full : %${length}s\n" "${_E3_TGT_URL_FULL}"
    printf ">> \n";

    if ! [ -z "${siteMods}" ]; then
	printf "e3 module is located in siteMods\n" 
    fi
    
    
}

options=":m:u:d:y"
SITEMODS="NO"

while getopts "${options}" opt; do
    case "${opt}" in
	m)
	    MODULE_CONF=${OPTARG} ;
	    ;;
	d)
	    targetpath="1";
	    E3_MODULE_PATH=${OPTARG};
	    ;;
	u)
	    updateSource="1";
	    EXIST_SRC_PATH=${OPTARG};
	    ;;
	y)
	    SITEMODS="YES";
	    ;;
	*)
	    usage
	    ;;
    esac
done
shift $((OPTIND-1))


if [ -z "${targetpath}" ]; then
    E3_MODULE_PATH=${PWD}
fi


if [ -z "${updateSource}" ]; then
    # REMOTE SRC or LOCAL SRC
    # The configuration file should contain the following two entries:
    #
    # EPICS_MODULE_NAME:=
    # E3_MODULE_SRC_PATH:=
    # E3_TARGET_URL:=

    if [[ $(checkIfFile "${MODULE_CONF}") -eq "NON_EXIST" ]]; then
	usage
    else
	_EPICS_MODULE_NAME="$(read_version "${MODULE_CONF}" "EPICS_MODULE_NAME")";
	_E3_MODULE_SRC_PATH="$(read_version "${MODULE_CONF}" "E3_MODULE_SRC_PATH")";
	e3_target_url="$(read_version "${MODULE_CONF}" "E3_TARGET_URL")";
	epics_mod_url="$(read_version "${MODULE_CONF}" "EPICS_MODULE_URL")";
#	site_mod_status="$(read_version "${MODULE_CONF}" "E3_SITEMODS")";

	
	# Not very good logic, but we remove all other special characters first,
	# then select only letter and digits,
	# then if they have -, we can use as module name
	
	if [[ $_EPICS_MODULE_NAME =~ [-+@()=!#$%^\&*|~]+ ]]; then
	    help_modulename "$_EPICS_MODULE_NAME"
	elif [[ $_EPICS_MODULE_NAME =~ [A-Za-z0-9]+ ]]; then
	    printf ">>\n";
	    printf "%s is used as module name.\n" "$_EPICS_MODULE_NAME"
	elif [[ $_EPICS_MODULE_NAME =~ [_]+ ]]; then
	    printf ">>\n";
	    printf "%s is used as module name.\n" "$_EPICS_MODULE_NAME"
	else
	    help_modulename "$_EPICS_MODULE_NAME"
	fi

	
	if [ -z "${epics_mod_url}" ] ; then
	    localsrc="1";
	else
	    remotesrc="1";
	fi

	if [ "$SITEMODS" == "NO" ]; then
	    siteApps="1";
	else
	    siteMods="1";
	fi
	
	if [ -z "${_EPICS_MODULE_NAME}" ] ; then
	    echo "EPICS_MODULE_NAME is not defined";
	    exit;
	fi
	if [ -z "${_E3_MODULE_SRC_PATH}" ] ; then
	    echo "E3_MODULE_SRC_PATH is not defined";
	    exit;
	fi
	
    fi

    _E3_MOD_NAME=e3-${_EPICS_MODULE_NAME}

    if ! [ -z "${remotesrc}" ]; then
	_E3_MODULE_GITURL_FULL=${epics_mod_url}/${_E3_MODULE_SRC_PATH}
    fi

    _E3_TGT_URL_FULL=${e3_target_url}/${_E3_MOD_NAME}

    E3_MODULE_DEST=${E3_MODULE_PATH}/${_E3_MOD_NAME};

    module_info;

    rm -rf ${E3_MODULE_DEST} ||  die 1 "We cannot remove directories ${E3_MODULE_DEST} : Please check it" ;
    mkdir -p ${E3_MODULE_DEST}/{configure/module,patch/Site,docs,cmds,template,opi,iocsh}  ||  die 1 "We cannot create directories : Please check it" ;
    touch ${E3_MODULE_DEST}/{cmds,template,opi,iocsh}/.keep
        
    ## Copy its original Module configuration file in docs
    cp ${MODULE_CONF} ${E3_MODULE_DEST}/docs/   ||  die 1 "We cannot copy ${MODULE_CONF} to ${E3_MODULE_DEST}/docs : Please check it" ;


    touch ${LOG}
    {
	printf ">>\n";
	printf "Script is used     : ${SC_SCRIPTNAME}\n";
	printf "Script Path        : ${SC_TOP}\n";
	printf "User               : ${SC_USER}\n";
	printf "Log Time           : ${SC_LOGDATE}\n";
	printf "e3 repo Hash       : ${SC_HASH}\n";
	
	module_info;
	
    } >> ${E3_MODULE_DEST}/docs/${LOG}



    ## Going into ${E3_MODULE_DEST}
    pushd ${E3_MODULE_DEST}

    git init ||  die 1 "We cannot git init in ${_E3_MOD_NAME} : Please check it" ;

    if ! [ -z "${localsrc}" ]; then
	_E3_MODULE_SRC_PATH+="-loc";
	echo ${_E3_MODULE_SRC_PATH}
	mkdir -p ${_E3_MODULE_SRC_PATH}/${_EPICS_MODULE_NAME}App/{Db,src} ||  die 1 "We cannot create directories : Please check it" ;

	if [[ "${_EPICS_MODULE_NAME}" =~ "example" ]]; then 
	    addExampleSrc  "${_E3_MODULE_SRC_PATH}/${_EPICS_MODULE_NAME}App/src" 
	    addExampleDb   "${_E3_MODULE_SRC_PATH}/${_EPICS_MODULE_NAME}App/Db" 
	    addExampleCmds "cmds"
	fi
    else
	add_submodule "${_E3_MODULE_GITURL_FULL}" "${_E3_MODULE_SRC_PATH}" ||  die 1 "We cannot add ${_E3_MODULE_GITURL_FULL} as git submodule ${_E3_MOD_NAME} : Please check it" ;
    fi

    ## add the default .gitignore
    add_gitignore


    ## add README.md
    if [ "$SITEMODS" == "YES" ]; then
	add_readme_siteMods
    else
	add_readme_siteApps;
    fi

    ## add Makefile for E3 front-end
    add_e3_makefile

    ## add ${_E3_MOD_NAME}.Makefile for E3
    ## This is the template file. One should change it accroding to their
    ## corresponding module
    if ! [ -z "${localsrc}" ]; then
	add_local_module_makefile "${_EPICS_MODULE_NAME}"
    else
	add_module_makefile  "${_EPICS_MODULE_NAME}"
    fi


    pushd patch/Site # Enter in patch/Site
    ## add patch path and readme and so on
    add_patch
    popd             # Back from patch/Site


    pushd configure  # Enter in configure
    if [ "$SITEMODS" == "YES" ]; then
	add_configure_siteMods
    else
	add_configure_siteApps;
    fi
    popd             # Back from configure


    pushd configure/module # Enter in configure/E3
    add_configure_module
    popd               # Back from configure/E3


    # # git init
    git add .


    printf "\n";
    printf  ">>>> Do you want to add the URL ${_E3_TGT_URL_FULL} for the remote repository?\n";
    printf  "     In that mean, you already create an empty repository at ${_E3_TGT_URL_FULL}.\n";
    printf  "\n";
    read -p "     If yes, the script will push the local ${_E3_MOD_NAME} to the remote repository. (y/N)? " answer
    case ${answer:0:1} in
	y|Y|yes|Yes|YES )
	    printf ">>>> We are going to the further process ...... ";
	    git remote add origin ${_E3_TGT_URL_FULL} ||  die 1 "Cannot add ${_E3_TGT_URL_FULL} in origin: Please check your git env!" ;
	    git commit -m "Init..${_E3_MOD_NAME}"     ||  die 1 "We cannot commit, maybe you need to run git config user and so on." ;
	    git push -u origin master                 ||  die 1 "Repository is not at ${_E3_TGT_URL_FULL} : Please create it first!" ;
	    
	    ;;
	* )
	    help;
	    ;;
    esac


    ## Going out from ${E3_MODULE_DEST}
    popd


    echo "";
    echo "The following files should be modified according to the module : "
    echo "";
    echo "   * ${E3_MODULE_DEST}/configure/CONFIG_MODULE"
    echo "   * ${E3_MODULE_DEST}/configure/RELEASE"
    echo "";
    echo "One can check the e3- template works via ";
    echo "   cd ${E3_MODULE_DEST}"
    echo "   make init"
    echo "   make vars"
    echo "";
    echo "";

else

    ### Update the latest configuration files for an existent module or IOC applications

    UPDATE_TOP=${EXIST_SRC_PATH}

    if [[ $(checkIfDir "${EXIST_SRC_PATH}") -eq "$NON_EXIST" ]]; then
	printf ">>\n"
	printf "  We cannot find %s\n" "${EXIST_SRC_PATH}"
	printf ">>\n";
	usage
    fi

    if [[ "$(basename ${UPDATE_TOP})" =~ "e3-require" ]] ; then
	warning_path "$(basename ${UPDATE_TOP})"
    elif [[ "$(basename ${UPDATE_TOP})" =~ "e3-base" ]] ; then
	warning_path "$(basename ${UPDATE_TOP})"
    fi

    pushd ${UPDATE_TOP}
    ## Get all branches
    git fetch origin

    BRANCH="master";

    if ! git checkout ${BRANCH}; then
    echo -e >&2 "\n>>\n  Please check ${PWD}.\n  It might not be a git repository or we cannot find the branch ${BRANCH}.";
    exit 1
    fi
    
    ## STOP if any changes are exist in ${BRANCH}
    any_changes=$(git status --porcelain --untracked-files=no)
    
    if ! [ -z "${any_changes}" ] ; then
    	die "ERROR : the ${BRANCH} branch was changed, please commit them first."
    fi

    ## The following directory will be created if there is no directory.
    ## If the directory exists, th existent files are intact.
    declare -ga directory_list=("docs" "cmds" "template" "opi" "iocsh");

    for a_dir in ${directory_list[@]}; do
	if [[ $(checkIfDir "${a_dir}") -eq "$NON_EXIST" ]]; then
	    mkdir -p ${a_dir}  ||  die 1 "We cannot create directories : Please check it" ;
	    touch ${a_dir}/.keep
	fi
    done
    
    {
	printf "\n>>\n";
	printf "Update Log Time    : ${SC_LOGDATE}\n";
	printf ">>\n";
	printf "Script is used     : ${SC_SCRIPTNAME}\n";
	printf "Script Path        : ${SC_TOP}\n";
	printf "User               : ${SC_USER}\n";
	printf "e3 repo Hash       : ${SC_HASH}\n";

	CONFIG_MODULE=configure/CONFIG_MODULE
	RELEASE_BASE=configure/RELEASE
	
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
		_EPICS_MODULE_NAME="$(read_version "${CONFIG_MODULE}" "EPICS_MODULE_NAME")";
		
	    fi
	else
	    # If a repository is e3-require, we use the require version as module version
	    #
	    module_version=${require_version}
	fi
	printf "\n"
	printf "EPICS_MODULE_NAME  : %34s\n" "${_EPICS_MODULE_NAME}"
	printf "E3 MODULE VERSION  : %34s\n" "${module_version}"
	printf "EPICS BASE VERSION : %34s\n" "${base_version}"
	printf "E3 REQUIRE VERSION : %34s\n" "${require_version}"
	printf ">>\n";
	
    } >> docs/${UPDATE_LOG}


    # We have to use 3.0.4 require this time
    # We will remove the following hard-code version later.
    # Friday, November  9 15:28:18 CET 2018
    require_version="3.0.4";

    echo ${PWD}

    module_makefile=${_EPICS_MODULE_NAME}.Makefile
    
    printf ">>\n"
    printf "  Replace old DECOUPLE_FLAGS within %s\n" "${module_makefile}"
    
    sed -i~ "s:^include \$(where_am_I).*:include \$(E3_REQUIRE_CONFIG)/DECOUPLE_FLAGS:g" ${module_makefile}

    printf "  Can you see the difference between them? If you see nothing, we don't need to update %s.\n" "${module_makefile}"
    printf "  ---------------------------------------------------------------------------------------------------------\n"
    diff ${module_makefile}~ ${module_makefile}
    printf "  ---------------------------------------------------------------------------------------------------------\n"

    
    vlibs_status=$(grep -r vlibs: ${module_makefile})

    if [[ $(checkIfVar "${vlibs_status}") -eq "$NON_EXIST" ]]; then
	echo "#"             >> ${module_makefile}
	echo ".PHONY: vlibs" >> ${module_makefile}
	echo "vlibs:"        >> ${module_makefile}
	echo "#"             >> ${module_makefile}
    fi
    
    WORKING_PATH="patch/Site"
    printf ">>\n"
    printf "  Check %s .......\n" "${WORKING_PATH}"
    if [[ $(checkIfDir "${WORKING_PATH}") -eq "$NON_EXIST" ]]; then
	printf "  Creating path ....\n";
	mkdir -p ${WORKING_PATH}  ||  die 1 "We cannot create directories : Please check it" ;
	pushd ${WORKING_PATH}
	#	patchfile_count=$(ls *.patch 2>/dev/null | wc -l)
	printf "  Add the default patch README, and HISTORY files\n";
	add_patch
	popd
    else
	printf "  Path exist %s\n" "${WORKING_PATH}"
	printf "  Skip it\n";
    fi

    WORKING_PATH="configure/E3"
    printf ">>\n"
    printf "  Check %s .......\n" "${WORKING_PATH}"
    if [[ $(checkIfDir "${WORKING_PATH}") -eq "$EXIST" ]]; then
	printf "  Not Removing path ....\n";
	printf "  One should check their changes with configure/module carefully\n";
	# 	rm -rf ${WORKING_PATH}  ||  die 1 "We cannot create directories : Please check it" ;

    fi

    WORKING_PATH="configure/module"
    printf ">>\n"
    printf "  Check %s .......\n" "${WORKING_PATH}"
    if [[ $(checkIfDir "${WORKING_PATH}") -eq "$NON_EXIST" ]]; then
	printf "  Creating path ....\n";
	mkdir -p ${WORKING_PATH}  ||  die 1 "We cannot create directories : Please check it" ;
	pushd ${WORKING_PATH}
	printf "  Add the default configure/module files....\n";
	add_configure_module
	popd
    else
	printf "  Working path %s exists\n" "${WORKING_PATH}"      ;
	printf "  Do you want to update all files up-to-date?\n" ;
	yes_or_no_to_go
	pushd ${WORKING_PATH}
	printf "  Add the default configure/module files....\n";

	# TARGET_FILE=RULES_MODULE
	# if [[ $(checkIfFile "${TARGET_FILE}") -eq "NON_EXIST" ]]; then
	#     add_rules_modules;
	# else
	#     printf "  %s exists, not update it\n" "${TARGET_FILE}";
	# fi

	TARGET_FILE=RULES_MODULE
	if [[ $(checkIfFile "${TARGET_FILE}") -eq "NON_EXIST" ]]; then
	    add_rules_module;
	else
	    printf "  %s exists, not update it\n" "${TARGET_FILE}";
	fi
	
	TARGET_FILE=RULES_DKMS_L
	if [[ $(checkIfFile "${TARGET_FILE}") -eq "NON_EXIST" ]]; then
	    add_rules_dkms_l;
	else
	    printf "  %s exists, not update it\n" "${TARGET_FILE}";
	fi

	popd
    fi

    
        
    WORKING_PATH="configure"
    printf ">>\n"
    printf "  Check %s .......\n" "${WORKING_PATH}"
    if [[ $(checkIfDir "${WORKING_PATH}") -eq "$NON_EXIST" ]]; then
	printf "  Creating path ....\n";
	mkdir -p ${WORKING_PATH}  ||  die 1 "We cannot create directories : Please check it" ;
	pushd ${WORKING_PATH}
	if [ "$SITEMODS" == "YES" ]; then
	    add_configure_siteMods
	else
	    add_configure_siteApps
	fi
	popd
    else

	printf "  $WORKING_PATH exists.\n"
	pushd ${WORKING_PATH}

	
	if [[ $(checkIfFile "DECOUPLE_FLAGS") -eq "$EXIST" ]]; then
	    printf "  Remove %s\n" "DECOUPLE_FLAGS"
	    rm -f DECOUPLE_FLAGS
	fi

	if [ "$SITEMODS" == "YES" ]; then
	    printf ">>\n"
	    printf "  We are entering in SITEMODS.  \n";
	    printf "  Is this right? \n" ;
	    yes_or_no_to_go
	    
	    # CONFIG should be updated
	    printf ">>\n"
	    printf "  Update CONFIG...\n";
	    add_CONFIG_siteMods;

	    # RELEASE should be updated according to existent VERSION info
	    printf ">>\n"
	    printf "  Update RELEASE...with %s %s \n" "${base_path}" "${require_version}";
	    add_RELEASE_Update "${base_path}" "${require_version}";

	    # CONFIG_MODULE
	    printf ">>\n";
	    printf "  Update CONFIG_MODULE ...\n";
	    file=$(mktemp -q) && {
		read_config_module "CONFIG_MODULE" > "$file"
		scp "$file" "CONFIG_MODULE"
		rm "$file"
	    }
	    file=$(mktemp -q) && {
		read_config_module "CONFIG_MODULE_DEV" > "$file"
		scp "$file" "CONFIG_MODULE_DEV"
		rm "$file"
	    }

	    # RULES should be updated
	    printf ">>\n";
	    printf "  Update RULES ...\n";
	    add_RULES_siteMods;
	    
	    # CONFIG_OPTIONS
	    if [[ $(checkIfFile "CONFIG_OPTIONS") -eq "$NON_EXIST" ]]; then
		add_CONFIG_OPTIONS;
	    else
		printf ">>\n";
		printf "  We've found CONFIG_OPTIONS. Skip it\n";
	    fi
	else
	    printf ">>\n"
	    printf "  We are entering in SITEAPPS.  \n";
	    printf "  Is this right? \n" ;
	    yes_or_no_to_go

	    # CONFIG should be updated
	    printf ">>\n"
	    printf "  Update CONFIG...\n";
	    add_CONFIG_siteApps;
	    
	    # RELEASE should be updated according to existent VERSION info
	    printf ">>\n"
	    printf "  Update RELEASE...with %s %s \n" "${base_path}" "${require_version}";
	    add_RELEASE_Update "${base_path}" "${require_version}";

	    # CONFIG_MODULE
	    printf ">>\n";
	    printf "  Update CONFIG_MODULE ...\n";
	    file=$(mktemp -q) && {
		read_config_module "CONFIG_MODULE" > "$file"
		scp "$file" "CONFIG_MODULE"
		rm "$file"
	    }
	    file=$(mktemp -q) && {
		read_config_module "CONFIG_MODULE_DEV" > "$file"
		scp "$file" "CONFIG_MODULE_DEV"
		rm "$file"
	    }
	    
	    # RULES should be updated
	    printf ">>\n";
	    printf "  Update RULES ...\n";
	    add_RULES_siteApps;
	     # CONFIG_OPTIONS
	    if [[ $(checkIfFile "CONFIG_OPTIONS") -eq "$NON_EXIST" ]]; then
		add_CONFIG_OPTIONS;
	    else
		printf ">>\n";
		printf "  We've found CONFIG_OPTIONS. Skip it\n";
	    fi
	fi
	popd
    fi
    
    popd # back from ${UPDATE_TOP}

    help_update;
    
fi

exit

