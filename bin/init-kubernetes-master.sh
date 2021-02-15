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
config=/tmp/$( uuidgen ).yaml                                           ;
sleep=10                                                                ;
log=/tmp/$( uuidgen ).log                                               ;
#########################################################################
echo ${InstanceMaster1} ${kube}                                         \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
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
sudo tee ${config} 0<<EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cgroup-driver: systemd
---
apiVersion: kubeadm.k8s.io/v1beta2
controlPlaneEndpoint: "${kube}:6443"
kind: ClusterConfiguration
networking:
  podSubnet: ${pod_network_cidr}
---
EOF
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
        sudo                                                            \
                ${token_token}                                          \
                ${token_discovery}                                      \
                ${token_certificate}                                    \
                --config                                                \
                        ${config}                                       \
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
rm --force ${config}                                                    ;
#########################################################################
#sudo sed --in-place                                                     \
#        /${kube}/d                                                      \
#        /etc/hosts                                                      ;
#sudo sed --in-place                                                     \
#        /127.0.0.1.*localhost/s/$/' '${kube}/                           \
#        /etc/hosts                                                      ;
#########################################################################
