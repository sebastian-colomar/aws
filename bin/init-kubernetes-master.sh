#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${InstanceMaster1}"    || exit 201                             ;
test -n "${kube}"               || exit 202                             ;
test -n "${token_certificate}"  || exit 203                             ;
test -n "${token_discovery}"    || exit 204                             ;
test -n "${token_token}"        || exit 205                             ;
#########################################################################
log=/tmp/$( uuidgen ).log                                               ;
sleep=10                                                                ;
#########################################################################
echo ${InstanceMaster1} ${kube}                                         \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
#########################################################################
token_certificate="$(                                                   \
        echo ${token_certificate}                                       \
        |                                                               \
        base64 --decode                                                 \
)"                                                                      ;
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
        sudo                                                            \
                ${token_token}                                          \
                ${token_discovery}                                      \
                ${token_certificate}                                    \
                --ignore-preflight-errors                               \
                        all                                             \
                2>& 1                                                   \
        |                                                               \
        tee ${log}                                                      ;
        grep 'This node has joined the cluster' ${log}                  \
        &&                                                              \
        rm --force ${log}                                               \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
sudo sed --in-place                                                     \
        /${kube}/d                                                      \
        /etc/hosts                                                      ;
sudo sed --in-place                                                     \
        /127.0.0.1.*localhost/s/$/' '${kube}/                           \
        /etc/hosts                                                      ;
#########################################################################
