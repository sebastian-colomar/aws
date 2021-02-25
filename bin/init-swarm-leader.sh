#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${InstanceMaster1}"    || exit 101                             ;
test -n "${log}"                || exit 103                             ;
#########################################################################
sleep=10                                                                ;
success='^Swarm initialized: current node .* is now a manager'		;
#########################################################################
while true                                                              ;
do                                                                      \
        grep                                                            \
                "${success}"                                            \
                ${log}                                                  \
        &&                                                              \
        break                                                           ;
        sudo                                                            \
		docker 							\
			swarm 						\
				init 					\
					--advertise-addr 		\
						${InstanceMaster1} 	\
                                                                        ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo                                                            \
		docker 							\
			node 						\
				ls 					\
        |                                                               \
        grep Ready                                                      \
        |                                                               \
        grep --invert-match NotReady                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
