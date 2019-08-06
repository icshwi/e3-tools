#!/bin/bash
#
#  Copyright (c) 2019 European Spallation Source ERIC
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
# Date    : Tuesday, August  6 08:58:25 CEST 2019
# version : 1.0.0

sudo apt-get -qq update  > /dev/null 2>&1 
sudo apt-get install -y linux-headers-$(uname -r)   > /dev/null 2>&1 
sudo apt-get install -y build-essential realpath ipmitool libtool automake tclx  tree screen re2c darcs  > /dev/null 2>&1 
sudo apt-get install -y libreadline-dev libxt-dev x11proto-print-dev libxmu-headers libxmu-dev libxpm-dev libxmuu-dev libxmuu1 libpcre++-dev python-dev libnetcdf-dev libhdf5-dev libpng-dev libbz2-dev libxml2-dev libusb-dev libusb-1.0-0-dev libudev-dev libsnmp-dev libraw1394-dev libboost-dev libboost-regex-dev libboost-filesystem-dev libopencv-dev > /dev/null 2>&1
sudo apt-get install -y libtirpc-dev > /dev/null 2>&1

mkdir -p ${E3_SRC_PATH}
pushd ${E3_SRC_PATH}

git clone https://github.com/icshwi/e3
pushd e3
bash e3_building_config.bash -y -t "${E3_PATH}" -b "${BASE}" -r "${REQUIRE}" -c "${TAG}" setup > /dev/null 2>&1
bash e3.bash gbase                      > /dev/null 2>&1
bash e3.bash ibase                      > /dev/null 2>&1
bash e3.bash bbase                      
bash e3.bash req
bash e3.bash -c mod
popd

popd

