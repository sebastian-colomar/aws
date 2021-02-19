#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${InstanceMaster1}"    || exit 301                             ;
test -n "${InstanceMaster2}"    || exit 302                             ;
test -n "${InstanceMaster3}"    || exit 303                             ;
test -n "${kube}"               || exit 304                             ;
test -n "${port}"               || exit 305                             ;
#########################################################################
branch=docker                                                           ;
compose=etc/kubernetes/manifests/nlb.yaml                               ;
file=/etc/hosts                                                         ;
kubeconfig=/etc/kubernetes/admin.conf                                   ;
namespace=kube-lb                                                       ;
pattern=127.0.0.1.*localhost                                            ;
repository=https://github.com/academiaonline/nlb                        ;
sleep=10                                                                ;
uuid=/tmp/$( uuidgen )                                                  ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status docker                                         \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
git clone                                                               \
        --single-branch --branch ${branch}                              \
        ${repository}                                                   \
        ${uuid}                                                         ;
sed --in-place s/ip1/${InstanceMaster1}/                                \
        ${uuid}/${compose}                                              ;
sed --in-place s/ip2/${InstanceMaster2}/                                \
        ${uuid}/${compose}                                              ;
sed --in-place s/ip3/${InstanceMaster3}/                                \
        ${uuid}/${compose}                                              ;
sed --in-place s/nlb/${namespace}/                                      \
        ${uuid}/${compose}                                              ;
sed --in-place s/port1/${port}/                                         \
        ${uuid}/${compose}                                              ;
sed --in-place s/port2/${port}/                                         \
        ${uuid}/${compose}                                              ;
sed --in-place s/port3/${port}/                                         \
        ${uuid}/${compose}                                              ;
#########################################################################
sudo kubectl                                                            \
        --kubeconfig ${kubeconfig}                                      \
        create ns ${namespace}                                          ;
sudo kubectl                                                            \
        --kubeconfig ${kubeconfig}                                      \
        --namespace ${namespace}                                        \
        apply --filename ${compose}                                     ;
#########################################################################
rm --recursive --force ${uuid}                                          ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo kubectl                                                    \
                --kubeconfig ${kubeconfig}                              \
                --namespace ${namespace}                                \
                get ds ${namespace}                                     \
        |                                                               \
        grep '\([0-9]\)/\1'                                             \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
grep ${pattern}.*${kube} ${file}                                        \
||                                                                      \
sudo sed --in-place                                                     \
        /${kube}/d                                                      \
        ${file}                                                         \
&&                                                                      \
sudo sed --in-place                                                     \
        '/${pattern}/s/$/ ${kube}/'                                     \
        ${file}                                                         \
                                                                        ;
#########################################################################
