#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
kubeconfig=/etc/kubernetes/admin.conf                                   ;
sleep=10                                                                ;
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
        grep Ready                                                      \
        |                                                               \
        grep NotReady                                                   \
        &&                                                              \
        continue                                                        \
        ||                                                              \
        break                                                           ;
done                                                                    ;
#########################################################################
