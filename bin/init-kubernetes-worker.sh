#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${InstanceMaster1}"    || exit 201                             ;
test -n "${kube}"               || exit 202                             ;
test -n "${log}"                || exit 203                             ;
test -n "${token_discovery}"    || exit 204                             ;
test -n "${token_token}"        || exit 205                             ;
#########################################################################
file=/etc/hosts                                                         ;
sleep=10                                                                ;
success='This node has joined the cluster'                              ;
#########################################################################
grep ${InstanceMaster1}\ ${kube} ${file}                                \
||                                                                      \
echo ${InstanceMaster1} ${kube}                                         \
|                                                                       \
sudo tee --append ${file}                                               ;
#########################################################################
token_discovery="$(                                                     \
        echo ${token_discovery}                                         \
        |                                                               \
        base64 --decode                                                 \
)"                                                                      ;
token_token="$(                                                         \
        echo ${token_token}                                             \
        |                                                               \
        base64 --decode                                                 \
)"                                                                      ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo systemctl is-enabled kubelet                               \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
while true                                                              ;
do                                                                      \
        grep                                                            \
                "${success}"                                            \
                ${log}                                                  \
        &&                                                              \
        break                                                           ;
        sudo                                                            \
                ${token_token}                                          \
                        ${token_discovery}                              \
                        --ignore-preflight-errors                       \
                                all                                     \
                                                                        ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
rm --force ${log}                                                       ;
#########################################################################
