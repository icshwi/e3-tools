#!/bin/bash
#
#  Copyright (c) 2018 Jeong Han Lee
#  Copyright (c) 2018 European Spallation Source ERIC
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
# Date    : Friday, September 21 01:01:15 CEST 2018
#
# version : 0.0.2

# Only aptitude can understand the extglob option
shopt -s extglob

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -gr SUDO_CMD="sudo";

declare -g KERNEL_VER=$(uname -r)


function find_dist
{

    local dist_id dist_cn dist_rs PRETTY_NAME
    
    if [[ -f /usr/bin/lsb_release ]] ; then
     	dist_id=$(lsb_release -is)
     	dist_cn=$(lsb_release -cs)
     	dist_rs=$(lsb_release -rs)
     	echo "$dist_id ${dist_cn} ${dist_rs}"
    else
     	eval $(cat /etc/os-release | grep -E "^(PRETTY_NAME)=")
	echo "${PRETTY_NAME}"
    fi
 
}

function yes_or_no_to_go
 {

    printf  "> \n";
    printf  "> Linux RT Kernel Installation.\n"
    printf  "> \n";
    printf  "> $1\n";
    read -p ">> Do you want to continue (y/N)? " answer
    case ${answer:0:1} in
	y|Y )
	    printf ">> The following kernel will be installed ......\n ";
	    ;;
	* )
            printf ">> Stop here.\n";
	    exit;
    ;;
    esac

}


function centos_rt_repo
{
    ${SUDO_CMD} tee /etc/yum.repos.d/CentOS-rt.repo >/dev/null <<"EOF"
#
#
# CERN CentOS 7 RealTime repository at http://linuxsoft.cern.ch/
#

[rt]
name=CentOS-$releasever - RealTime
baseurl=http://linuxsoft.cern.ch/cern/centos/$releasever/rt/$basearch/
gpgcheck=1
enabled=1
protect=1
priority=10
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern

[rt-debug]
name=CentOS-$releasever - RealTime - Debuginfo
baseurl=http://linuxsoft.cern.ch/cern/centos/$releasever/rt/Debug/$basearch/
gpgcheck=1
enabled=0
protect=1
priority=10
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern

[rt-source]
name=CentOS-$releasever - RealTime - Sources
baseurl=http://linuxsoft.cern.ch/cern/centos/$releasever/rt/Sources/
gpgcheck=1
enabled=0
protect=1
priority=10
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern

EOF

    ${SUDO_CMD} rpm --import http://linuxsoft.cern.ch/cern/centos/7/os/x86_64/RPM-GPG-KEY-cern
    ${SUDO_CMD} yum update -y
    ${SUDO_CMD} yum -y install kernel-rt-devel
    ${SUDO_CMD} yum -y groupinstall RT
#    ${SUDO_CMD} yum install -y kernel-rt rt-tests tuned-profiles-realtime

}

ANSWER="NO"

dist=$(find_dist)

case "$dist" in
    *"stretch"*)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go "Debian Stretch 9 is detected as $dist"
	fi
	# apt, apt-get cannot handle extglob, so aptitude
	# in order to exclude -dbg kernel image. However, aptitude install
	# doesn't understand extglob, only search can do. 
	
	${SUDO_CMD} apt install -y aptitude
	rt_image=$(aptitude search linux-image-rt!(dbg) | awk '{print $2}')
	${SUDO_CMD} apt install -y linux-headers-rt* ${rt_image}
	;;
    *"CentOS Linux 7"*)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go "CentOS Linux 7 is detected as $dist"
	fi
	centos_rt_repo;
	;;
    *)
	printf "\n";
	printf "Doesn't support the detected $dist\n";
	printf "Please contact jeonghan.lee@gmail.com\n";
	printf "\n";

	;;
esac

exit
