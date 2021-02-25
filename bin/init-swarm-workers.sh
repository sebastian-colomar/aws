#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x									;
#########################################################################
test -n "${branch}"		|| exit 101                             ;
test -n "${domain}"		|| exit 103                             ;
test -n "${engine}"		|| exit 104                             ;
test -n "${mode}"		|| exit 106                             ;
test -n "${os}"			|| exit 107				;
test -n "${path}"		|| exit 108                             ;
test -n "${repository}"		|| exit 110                             ;
test -n "${stack}"		|| exit 111                             ;
test -n "${username}"		|| exit 112                             ;
test -n "${version_major}"	|| exit 113                             ;
test -n "${version_minor}"	|| exit 114                             ;
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
service=${engine}							;
targets="                                                               \
        InstanceWorker1                                                 \
        InstanceWorker2                                                 \
        InstanceWorker3                                                 \
"									;
#########################################################################
file=install-${service}-${os}.sh					;
log=/tmp/${file}.log							;
#########################################################################
export="                                                                \
        export version_major=${version_major}                           \
"                                                                       ;
#########################################################################
__send_list_command_remote						;
#########################################################################
role=leader								;
targets="                                                               \
        InstanceMaster1                                                 \
"									;
#########################################################################
file=init-${mode}-${role}.sh						;
log=/tmp/${file}.log							;
#########################################################################
role=worker                                                             ;
#########################################################################
command="                                                               \
        sudo docker swarm join-token ${role}                            \
        |                                                               \
        grep --max-count 1                                              \
                ${token}                                                \
"									;
#########################################################################
eval token_${role}=$(                                                   \
        _encode_string "                                                \
                $(                                                      \
                        _send_list_command_targets_wait                 \
                                "${command}"                            \
                                ${sleep}                                \
                                ${stack}                                \
                                "${targets}"                            \
                )                                                       \
       "                                                                ;
)									;
#########################################################################
role=worker								;
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
        export log=${log}                                               \
        &&                                                              \
        export token_token=${token_worker}                              \
"									;
#########################################################################
__send_list_command_remote						;
#########################################################################
