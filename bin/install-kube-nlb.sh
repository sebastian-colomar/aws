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
branch=master                                                           ;
folder=docker
compose=etc/swarm/manifests/nlb.yaml                                    ;
file=/etc/hosts                                                         ;
namespace=kube-nlb                                                      ;
pattern=127.0.0.1.*localhost                                            ;
repository=https://github.com/sebastian-colomar/nlb                        ;
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
uuid=${uuid}/${folder}        
sed --in-place s/worker/manager/                                        \
        ${uuid}/${compose}                                              ;
sed --in-place s/port_master/${port}/                                   \
        ${uuid}/${compose}                                              ;
sed --in-place s/port_master/${port}/                                   \
        ${uuid}/run/secrets/etc/nginx/conf.d/default.conf               ;
sed --in-place s/ip_master1/${InstanceMaster1}/                         \
        ${uuid}/run/secrets/etc/nginx/conf.d/default.conf               ;
sed --in-place s/ip_master2/${InstanceMaster2}/                         \
        ${uuid}/run/secrets/etc/nginx/conf.d/default.conf               ;
sed --in-place s/ip_master3/${InstanceMaster3}/                         \
        ${uuid}/run/secrets/etc/nginx/conf.d/default.conf               ;
sudo cp --recursive --verbose ${uuid}/run/* /run                        ;
sudo docker swarm init                                                  ;
sudo docker stack deploy --compose-file ${uuid}/${compose} ${namespace} ;
rm --recursive --force ${uuid}                                          ;
while true                                                              ;
do                                                                      \
        sleep 1                                                         ;
        sudo docker service ls | grep '\([0-9]\)/\1' && break           ;
done                                                                    ;
sudo rm --recursive --force /run/secrets /run/configs                   ;
#########################################################################
grep ${pattern}.*${kube} ${file}                                        \
||                                                                      \
sudo sed --in-place                                                     \
        /${kube}/d                                                      \
        ${file}                                                         \
&&                                                                      \
sudo sed --in-place                                                     \
        "/${pattern}/s/$/ ${kube}/"                                     \
        ${file}                                                         \
                                                                        ;
#########################################################################
