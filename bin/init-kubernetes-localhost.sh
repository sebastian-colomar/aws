#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x									;
#########################################################################
test -n "${branch}"		|| exit 101                             ;
test -n "${domain}"		|| exit 103                             ;
test -n "${kube}"		|| exit 105                             ;
test -n "${mode}"		|| exit 106                             ;
test -n "${path}"		|| exit 108                             ;
test -n "${repository}"		|| exit 110                             ;
test -n "${stack}"		|| exit 111                             ;
test -n "${username}"		|| exit 112                             ;
#########################################################################
function __send_list_command_remote { 					\
	_send_list_command_remote                                       \
		${branch}                                               \
		"${export}"                                             \
		${file}                                                 \
		${log}                                                  \
		${path}                                                 \
		${sleep}                                                \
		${stack}                                                \
		"${targets}"                                            \
		${url}                                                  \
                                                                        ;
}
#########################################################################
sleep=10								;
#########################################################################
url=${domain}/${username}/${repository}					;
#########################################################################
role=worker-localhost                                                   ;
targets="                                                               \
        InstanceWorker1                                                 \
        InstanceWorker2                                                 \
        InstanceWorker3                                                 \
"									;
#########################################################################
file=init-${mode}-${role}.sh						;
log=/tmp/${file}.log							;
#########################################################################
export="                                                                \
        export kube=${kube}                                             \
"									;
#########################################################################
__send_list_command_remote						;
#########################################################################
