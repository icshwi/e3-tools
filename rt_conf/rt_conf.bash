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
# Date    : Friday, September 21 15:13:17 CEST 2018
#
# version : 0.0.3

# Only aptitude can understand the extglob option
shopt -s extglob

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -gr SUDO_CMD="sudo";

declare -g KERNEL_VER=$(uname -r)

declare -g GRUB_CONF=/etc/default/grub
#declare -g GRUB_CONF=${SC_TOP}/grub

declare -g SED="sed -i"

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


function find_existent_boot_parameter
{

    local GRUB_CMDLINE_LINUX
    eval $(cat ${GRUB_CONF} | grep -E "^(GRUB_CMDLINE_LINUX)=")
    echo "${GRUB_CMDLINE_LINUX}"
 
}


function yes_or_no_to_go
{


    printf  "\n";
    
    printf  "*************** Warning!!! ***************\n";
    printf  "*************** Warning!!! ***************\n";
    printf  "*************** Warning!!! ***************\n";
    printf  ">\n";
    printf  "> You should know how to recover them if it doesn't work!\n";
    printf  ">\n";
     
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


function centos_rt_conf
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
    ${SUDO_CMD} yum -y groupinstall RT
    ${SUDO_CMD} yum -y install kernel-rt-devel tuned-profiles-realtime


}


function debian_rt_conf
{
    # apt, apt-get cannot handle extglob, so aptitude
    # in order to exclude -dbg kernel image. However, aptitude install
    # doesn't understand extglob, only search can do. 
    rt_image=$(aptitude search linux-image-rt!(dbg) | awk '{print $2}')
    ${SUDO_CMD} apt install -y linux-headers-rt* ${rt_image}
    
}

function centos_pkgs
{
    local remove_pkg_name="postfix sendmail";
    printf "Removing .... %s\n" ${remove_pkg_name}
    ${SUDO_CMD} yum -y remove postfix sendmail
    printf "Installing .... ethtool\n";
    ${SUDO_CMD} yum -y install ethtool
}

function debian_pkgs
{
    local remove_pkg_name="postfix sendmail";
    printf "Removing .... %s\n" ${remove_pkg_name}
    ${SUDO_CMD} apt remove -y postfix sendmail
    printf "Installing .... ethtool\n";
    ${SUDO_CMD} apt install -y aptitude ethtool
}

function disable_system_service
{
    local disable_services=irqbalance
    # disable_services+=pcscd
    
    printf "Disable service ... %s\n" "${disable_services}"
    ${SUDO_CMD} systemctl stop ${disable_services}
    ${SUDO_CMD} systemctl disable ${disable_services}

    # PC CARD Daemon                                                                                                                                                                                                                                                                                                                              
    #    ${SUDO_CMD} systemctl stop pcscd 
    #    ${SUDO_CMD} systemctl disable pcscd
}


function boot_parameters_conf
{

    local grub_cmdline_linux=$(find_existent_boot_parameter)
    
    local real_time_boot_parameter="idle=poll intel_idle.max_cstate=0 processor.max_cstate=1"

    printf "\n\n"
    printf "Now we are adding %s in GRUB_CMDLINE_LINUX= within the file %s\n" "${real_time_boot_parameter}" "${GRUB_CONF}"
    printf "If something goes wrong, please revert them as GRUB_CMDLINE_LINUX=\"%s\""  "${grub_cmdline_linux}"
    printf "\n\n\n\n"
    
    if [ -z "$grub_cmdline_linux" ]; then
	${SUDO_CMD} ${SED} "s/^GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"${real_time_boot_parameter}\"/g" ${GRUB_CONF}
    else
	${SUDO_CMD} ${SED} "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"${grub_cmdline_linux} ${real_time_boot_parameter}\"/g"  ${GRUB_CONF}
    fi

}



ANSWER="NO"

dist=$(find_dist)

case "$dist" in
    *"stretch"*)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go "Debian Stretch 9 is detected as $dist"
	fi
	debian_pkgs
	debian_rt_conf
	boot_parameters_conf
	${SUDO_CMD} update-grub
	;;
    *"CentOS Linux 7"*)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go "CentOS Linux 7 is detected as $dist"
	fi
	centos_pkgs;
	centos_rt_conf;
	boot_parameters_conf
	${SUDO_CMD} grub2-mkconfig –o /boot/grub2/grub.cfg
	;;
    *)
	printf "\n";
	printf "Doesn't support the detected $dist\n";
	printf "Please contact jeonghan.lee@gmail.com\n";
	printf "\n";
	exit;
	;;
esac

disable_system_service


printf "\n"
printf "Reboot your system in order to use the RT kernel\n";
printf "\n"

exit
