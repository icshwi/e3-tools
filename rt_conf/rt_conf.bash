#!/bin/bash
#
#  Copyright (c) 2018        Jeong Han Lee
#  Copyright (c) 2018 - 2019 European Spallation Source ERIC
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
# Date    : Tuesday, April 24 1354 CEST 2019
#
# version : 0.0.7

# Only aptitude can understand the extglob option
shopt -s extglob

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -gr SUDO_CMD="sudo";

declare -g KERNEL_VER=$(uname -r)

declare -g GRUB_CONF=/etc/default/grub
#declare -g GRUB_CONF=${SC_TOP}/grub

declare -g SED="sed"



function die
{
    error=${1:-1}
    ## exits with 1 if error number not given
    shift
    [ -n "$*" ] &&
	printf "%s%s: %s\n" "$scriptname" ${version:+" ($version)"} "$*" >&2
    exit "$error"
}

# the following function drop_from_path was copied from
# the ROOT build system in ${ROOTSYS}/bin/, and modified
# a little to return its result 
# Wednesday, July 11 23:19:00 CEST 2018, jhlee 
drop_from_path ()
{
    #
    # Assert that we got enough arguments
    if test $# -ne 2 ; then
	echo "drop_from_path: needs 2 arguments"
	return 1
    fi

    local p="$1"
    local drop="$2"

    local new_path=`echo "$p" | sed -e "s;:${drop}:;:;g" \
                 -e "s;:${drop};;g"   \
                 -e "s;${drop}:;;g"   \
                 -e "s;${drop};;g";`
    echo ${new_path}
}


set_variable ()
{
    if test $# -ne 2 ; then
	echo "set_variable: needs 2 arguments"
	return 1
    fi

    local old_path="$1"
    local add_path="$2"

    local new_path=""
    local system_old_path=""

    if [ -z "$old_path" ]; then
	new_path=${add_path}
    else
	system_old_path=$(drop_from_path "${old_path}" "${add_path}")
	if [ -z "$system_old_path" ]; then
	    new_path=${add_path}
	else
	    new_path=${add_path}:${system_old_path}
	fi
   
    fi

    echo "${new_path}"
    
}


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
    ${SUDO_CMD} yum clean all
    ${SUDO_CMD} yum update -y
# Somehow linuxsoft.cern.ch and CentOS doesn't have tuned 2.9.0 version, so
# update repo has 2.10.0, without the fixed version we cannot install RT group,
# so, we fixed the version 2.8.0 first on tuned. 
#
    ${SUDO_CMD} yum -y install tuned-profiles-realtime-2.8.0-5.el7_4.2 yum-plugin-versionlock | die 1 "ERROR: yum tuned-profiled-realtime-2.8.0, please check it manually."
    ${SUDO_CMD} yum versionlock tuned tuned-profiles-realtime | die 1 "ERROR: versionlock failed, please check it manually." 
    ${SUDO_CMD} yum -y install kernel-rt rt-setup rtcheck rtctl rteval rteval-common rteval-loads kernel-rt-devel  | die 1 "ERROR: install kernel-rt-devel, please check it manually."
    
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
    local disable_services=$1; shift
#    local disable_services=irqbalance
#    disable_services+=pcscd
    
    printf "Disable service ... %s\n" "${disable_services}"
    ${SUDO_CMD} systemctl stop ${disable_services}    | echo ">>> $disable_services do not exist"
    ${SUDO_CMD} systemctl disable ${disable_services} | echo ">>> $disable_services do not exist"

}


function boot_parameters_conf
{

    local grub_cmdline_linux="$(find_existent_boot_parameter)"
    # 
    # idle=pool               : forces the TSC clock to aviod entering the idle state
    # processor.max_cstate=1  : prevents the clock from entering deeper C-states (energy saving mode), so it does not become out of sync
    # intel_idle.max_cstate=0 : ensures sleep states are not entered:
    # skew_tick=1             : Reduce CPU performace spikes
    # * Red Hat Enterprise Linux for Real Time 7 Tuning Guide
    # * https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7

    local rt_boot_parameter="idle=poll intel_idle.max_cstate=0 processor.max_cstate=1 skew_tick=1"

    existent_cmdline=${grub_cmdline_linux}
    drop_cmdline_linux="${rt_boot_parameter}"
    
    grub_cmdline_linux=$(drop_from_path "${existent_cmdline}" "${drop_cmdline_linux}")


    grub_cmdline_linux+=" "
    grub_cmdline_linux+=${rt_boot_parameter}
    new_grub_cmdline_linux=\"${grub_cmdline_linux}\"

    echo ${new_grub_cmdline_linux}

    printf "\n\n";
    printf ">>>>>\n";
    printf "     We are adding %s into GRUB_CMDLINE_LINUX in the file %s.\n" "${rt_boot_parameter}" "${GRUB_CONF}"
    printf "     If something goes wrong, you can revert them with the backup file, e.g., grub.bk\n"
    printf "     Please check grub.bk in the %s\n" "${GRUB_CONF%/*}/"
    printf ">>>>>\n\n"

    ${SUDO_CMD} cp -b ${GRUB_CONF} ${GRUB_CONF%/*}/grub.bk

    ${SED} "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=${new_grub_cmdline_linux}|g" ${GRUB_CONF} | ${SUDO_CMD} tee ${GRUB_CONF}  >/dev/null



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

disable_system_service "pcscd"



printf "\n"
printf "Reboot your system in order to use the RT kernel\n";
printf "\n"

exit
