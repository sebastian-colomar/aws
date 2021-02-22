#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${role}" || exit 100                                           ;
#########################################################################
kubeconfig=/etc/kubernetes/admin.conf                                   ;
sleep=10                                                                ;
#########################################################################
test ${role} = master && pattern=${role}                                ;
test ${role} = worker && pattern=none                                   ;
#########################################################################
while true                                                              ;
do                                                                      \
        sleep ${sleep}                                                  ;
        sudo                                                            \
                kubectl                                                 \
                        --kubeconfig                                    \
                                ${kubeconfig}                           \
                        get                                             \
                                --no-headers                            \
                                no                                      \
        |                                                               \
        grep Ready.*${pattern}                                          \
        |                                                               \
        grep NotReady                                                   \
        &&                                                              \
        continue                                                        \
        ||                                                              \
        break                                                           ;
done                                                                    ;
#########################################################################
