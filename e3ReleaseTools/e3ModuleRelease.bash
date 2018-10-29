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
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_USER="$(whoami)"
declare -gr SC_HASH="$(git rev-parse --short HEAD)"


declare -g  module_version=""
declare -g  require_version=""
declare -g  base_version=""

. ${SC_TOP}/.e3_module_release_functions



function usage
{
    {
	echo "";
	echo "Usage    : $0 [-m <module_configuraton_file>] [-d <module_destination_path>] " ;
	echo "";
	echo "               -m : mandatory"
	echo "               -d : option ( \$PWD if not ) "
	echo "";
	echo "Examples in modules_conf  : ";
	echo "";
	echo " bash create_e3_modules.bash -m  snmp3.conf"
	echo " bash create_e3_modules.bash -m  snmp3.conf -d ~/testing"
	echo ""
	
    } 1>&2;
    exit 1; 
}


MODULE_TOP=${PWD}

CONFIG_MODULE=${MODULE_TOP}/configure/CONFIG_MODULE
RELEASE_BASE=${MODULE_TOP}/configure/RELEASE



if [[ $(checkIfFile "${CONFIG_MODULE}") -eq "NON_EXIST" ]]; then
    die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the file >>${CONFIG_MODULE}<<";
else
    module_version="$(read_file_get_string   "${CONFIG_MODULE}" "E3_MODULE_VERSION:=")";
fi


if [[ $(checkIfFile "${RELEASE_BASE}") -eq "NON_EXIST" ]]; then
    die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the file >>${RELEASE_BASE}<<";
else
    base_version="$(read_file_get_string "${RELEASE_BASE}" "EPICS_BASE=/epics/base-")";
    require_version="$(read_file_get_string "${RELEASE_BASE}" "E3_REQUIRE_VERSION:=")";
fi


echo $module_version
echo $base_version
echo $require_version

echo "Check $module_version exist"
branch_exist=$(git rev-parse --verify --quiet $module_version)

    
if [ -z "${branch_exist}" ] ; then
    echo "branch is not found";
else
    echo ${branch_exist}
fi
