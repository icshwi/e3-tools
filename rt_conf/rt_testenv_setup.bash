#!/usr/bin/env bash
#
#  Copyright (c) 2019        Jeong Han Lee
#  Copyright (c) 2019        European Spallation Source ERIC
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
# Date    : Thursday, November 28 13:54:11 CET 2019
#
# version : 0.0.4

# Only aptitude can understand the extglob option
shopt -s extglob

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"
declare -gr SC_LOGDATE="$(date +%y%m%d%H%M)"


. ${SC_TOP}/.cfgs/.functions


declare -gr LTP_PATH="${SC_TOP}/ltp"
declare -gr RTTESTS_PATH="${SC_TOP}/rt-tests"
declare -gr RTTESTS_INSTALL="${RTTESTS_PATH}/local"

declare -gr ltp_tag="201909030";
declare -gr rt_tests_tag="v1.5";
declare -gr SUDO_CMD="sudo";


function path_check
{
    local _path="$1";
    printf "what is this %s\n" ${_path}
    if [ -d "${_path}" ]; then
	printf ">>> We've found %s ..... Removing .... \n" "${_path}"
	printf "\n\n";
	rm -rf ${_path}
    fi
}

function setup_ltp
{
    local tags="$1"; shift;
    local path="$1"; shift;

    printf "\n\n";
    printf ">>> We are going to setup LTP .....\n"
    printf "\n\n";
    
    pushd ${SC_TOP}

    path_check "${path}"
      
    git clone https://github.com/linux-test-project/ltp.git ${path}
      
    pushd ${path}
    git checkout "$tags"
    make autotools
    ./configure
    popd
    
    pushd ${path}/testcases/realtime
    ./configure
    printf "make -s\n";
    make -s
    popd
    popd
}


function setup_rt_tests
{
    local tags="$1"; shift;
    local path="$1"; shift;
    printf "\n\n";
    printf ">>> We are going to setup rt-tests .....\n"
    printf "\n\n";
    
    pushd ${SC_TOP}

    path_check "${path}"
  
    git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git "${path}"
    pushd "${path}"
    git checkout ${tags}
    printf "make all -s\n"
    make all -s
#    sudo make install
    popd
    popd
    
}

function print_usages
{
    
    printf "\n\n";
    printf ">>> Please consult the following sites to do test... \n"
    printf "     LTP : https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/ltp\n";
    printf "rt-tests : https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests\n";


}


function centos_pkgs
{
    local installing_pkgs="autoconf";
    printf "Installing .... %s\n" "$installing_pkgs" ;
    ${SUDO_CMD} yum -y install ${installing_pkgs};
}

function debian_pkgs
{
    local installing_pkgs="autoconf";
    printf "Installing .... %s\n" "$installing_pkgs" ;
    ${SUDO_CMD} apt install -y "$installing_pkgs"
}




ANSWER="NO"

dist=$(find_dist)

case "$dist" in
    *"stretch"*)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go "Debian Stretch 9 is detected as $dist"
	fi
	debian_pkgs;
	;;
    *"CentOS Linux 7"*)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go "CentOS Linux 7 is detected as $dist"
	fi
	centos_pkgs;
	;;
    *)
	printf "\n";
	printf "Doesn't support the detected $dist\n";
	printf "Please contact jeonghan.lee@gmail.com\n";
	printf "\n";
	exit;
	;;
esac



setup_ltp  "$ltp_tag" "${LTP_PATH}";
setup_rt_tests "$rt_tests_tag" "$RTTESTS_PATH" ;
print_usages;
