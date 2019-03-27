#!/bin/bash
#  Copyright (c) 2019  Jeong Han Lee
#  Copyright (c) 2019  European Spallation Source ERIC
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
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Wednesday, March 27 21:15:10 CET 2019
# version : 0.0.2

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"
declare -g SC_VERSION="v0.0.2"


EXIST=1
NON_EXIST=0

SUDO="sudo"

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


function die
{
    error=${1:-1}
    ## exits with 1 if error number not given
    shift
    [ -n "$*" ] &&
	printf "%s%s: %s\n" "$scriptname" ${version:+" ($version)"} "$*" >&2
    exit "$error"
}

function get_latest_build
{
    local url="$1";
    local latest=$(curl -s -k $url | sed -e 's/<[^>]*>//g' | awk '{print $1}' | grep -o '^[0-9]*\/' |sort -r | head -1)
    echo $latest;
}

WGET_TOP_PATH="artifactory.esss.lu.se"
# the last / is mandatory for curl
WGET_PATH="${WGET_TOP_PATH}/artifactory/yocto/toolchain/"
TOOLCHAIN_URL="https://${WGET_PATH}"
TOOLCHAIN_LOCAL_PATH="${SC_TOP}/toolchain/"

#INTEL="cct-glibc-x86_64-cct-toolchain-corei7-64-toolchain-2.6-4.14.sh"
#IOXOS="ifc14xx-glibc-x86_64-ifc14xx-toolchain-ppc64e6500-toolchain-2.6-4.14.sh"


function download_toolchain
{
    local latest=$1;shift;
    
    wget -r -e robots=off -l1 -R "index.html*" -R "index.html.*" -A "*.sh" -A "SHA-*" ${TOOLCHAIN_URL}/${latest}
    mkdir -p ${TOOLCHAIN_LOCAL_PATH}
    mv ${WGET_PATH}/${latest}/*.sh ${TOOLCHAIN_LOCAL_PATH}/
    mv ${WGET_PATH}/${latest}/SHA* ${TOOLCHAIN_LOCAL_PATH}/
    rm -rf ${SC_TOP}/${WGET_TOP_PATH}
}


function install_toolchain
{
    local default_dir="DEFAULT_INSTALL_DIR"
    pushd ${TOOLCHAIN_LOCAL_PATH}
    for file in $(find . -type f -name "*.sh" ); do
	printf "\n"
	printf ">>>>> We are installing ${file} into ....\n";
	printf "=================================================\n"
	chmod +x $file
	aa=$(strings $file | grep ${default_dir}=\"/)
#	echo "${aa//\"}"
        export "${aa//\"}"
#	echo $DEFAULT_INSTALL_DIR
	sudo ./${file} -y
	sudo scp SHA-* $DEFAULT_INSTALL_DIR/
	printf "\n";
    done
    popd
    unset DEFAULT_INSTALL_DIR
}

build=$(get_latest_build "${TOOLCHAIN_URL}")

download_toolchain ${build}
install_toolchain

exit

