#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x									;
#########################################################################
test -n "${mode}"		|| exit 100                             ;
#########################################################################
file=common-functions.sh                                                ;
path=lib                                                                ;
role=nlb                                                                ;
#########################################################################
source ${path}/${file}                                                  ;
#########################################################################
file=init-${mode}-${role}.sh                                            ;
path=bin                                                                ;
#########################################################################
source ${path}/${file}                                                  ;
#########################################################################
