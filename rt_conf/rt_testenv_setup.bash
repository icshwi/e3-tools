#!/bin/bash
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
# Date    : Wednesday, May 15 23:33:14 CEST 2019
#
# version : 0.0.2

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

function setup_ltp
{
    pushd ${SC_TOP}
    git clone https://github.com/linux-test-project/ltp.git ${LTP_PATH}
      
    pushd ltp
    make autotools
    ./configure
    popd
    
    pushd ltp/testcases/realtime
    ./configure
    make -s
    popd
    popd
}


function setup_rt_tests
{
    pushd ${SC_TOP}
    git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git ${RTTESTS_PATH}
    pushd rt-tests
    git checkout stable/v1.0
    make all -s 
#    sudo make install
    popd
}


printf "\n\n";
printf ">>> We are going to setup LTP .....\n"
printf "\n\n";

setup_ltp


printf "\n\n";
printf ">>> We are going to setup rt-tests .....\n"
printf "\n\n";

setup_rt_tests

printf "\n\n";
printf ">>> Please consult the following sites to do test... \n"
printf "     LTP : https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/ltp\n";
printf "rt-tests : https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests\n";

