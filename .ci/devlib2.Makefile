#
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
# 
# Author  : Jeong Han Lee
# email   : han.lee@esss.se
# Date    : Wednesday, March 20 09:59:26 CET 2019
# version : 0.0.1
#

where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include ${E3_REQUIRE_TOOLS}/driver.makefile
include $(E3_REQUIRE_CONFIG)/DECOUPLE_FLAGS

COMMON:= common

ifeq ($(EPICS_VERSION)$(EPICS_REVISION)$(EPICS_MODIFICATION),3150)
# The MMIO definitions are included in EPICS Base >=3.15.1
HEADERS += $(COMMON)/os/default/epicsMMIO.h
HEADERS += $(COMMON)/epicsMMIODef.h
endif

ifeq ($(EPICS_VERSION)$(EPICS_REVISION),314)
HEADERS += $(COMMON)/os/default/epicsMMIO.h
HEADERS += $(COMMON)/os/default/epicsMMIODef.h

ifneq ($(findstring $(EPICS_MODIFICATION),1 2 3 4 5 6 7 8),)
HEADERS += $(COMMON)/epicsEndian.h
HEADERS += $(COMMON)/os/default/osdWireConfig.h
endif
endif


ifeq ($(WITH_EXPLORE),YES)

EXPLOREAPP:=exploreApp
EXPLORESRC:=$(EXPLOREAPP)/src
EXPLOREDB:=$(EXPLOREAPP)/Db

SOURCES += $(EXPLORESRC)/devexplore.cpp
SOURCES += $(EXPLORESRC)/devexplore_irq.cpp
SOURCES += $(EXPLORESRC)/devexplore_frib.cpp
SOURCES += $(EXPLORESRC)/devexplore_util.cpp

DBDS += $(EXPLORESRC)/exploreSupport.dbd

TEMPLATES += $(EXPLOREDB)/frib-flash.db
endif


PCIAPP:= pciApp

HEADERS += $(PCIAPP)/devLibPCI.h
HEADERS += $(PCIAPP)/devLibPCIImpl.h

SOURCES += $(PCIAPP)/devLibPCI.c
SOURCES += $(PCIAPP)/devLibPCIStrings.c
SOURCES += $(PCIAPP)/os/Linux/devLibPCIOSD.c
SOURCES += $(PCIAPP)/pcish.c

DBDS += $(PCIAPP)/epicspci.dbd


# We don't need the following parts in near future
#
VMEAPP:= vmeApp

HEADERS += $(VMEAPP)/devcsr.h
HEADERS += $(VMEAPP)/vmedefs.h

SOURCES += $(VMEAPP)/devcsr.c
SOURCES += $(VMEAPP)/iocreg.c
SOURCES += $(VMEAPP)/vmesh.c
SOURCES += $(VMEAPP)/devlib_compat.c

DBDS += $(VMEAPP)/epicsvme.dbd



# db rule is the default in RULES_E3, so add the empty one

db:
#
vlibs:
#
.PHONY: vlibs db
