#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${role}" || exit 100                                           ;
#########################################################################
function __check {                                                      \
        sudo                                                            \
                kubectl                                                 \
                        --kubeconfig                                    \
                                ${kubeconfig}                           \
                        get                                             \
                                --no-headers                            \
                                no                                      \
}                                                                       ;
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
        __check                                                         \
        |                                                               \
        grep NotReady.*${pattern}                                       \
        &&                                                              \
        continue                                                        ;
        __check                                                         \
        |                                                               \
        grep Ready.*${pattern}                                          \
        &&                                                              \
        break                                                           ;
done                                                                    ;
#########################################################################
echo "All ${role} nodes have joined the cluster"                        ;
#########################################################################
