#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${calico}"             || exit 101                             ;
test -n "${kube}"               || exit 102                             ;
test -n "${InstanceMaster1}"    || exit 103                             ;
test -n "${log}"                || exit 104                             ;
test -n "${pod_network_cidr}"   || exit 105                             ;
#########################################################################
config=/tmp/$( uuidgen ).yaml                                           ;
file=/etc/hosts                                                         ;
kubeconfig=/etc/kubernetes/admin.conf                                   ;
sleep=10                                                                ;
success='^Your Kubernetes control-plane has initialized successfully'   ;
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
grep ${InstanceMaster1}\ ${kube} ${file}                                \
||                                                                      \
echo ${InstanceMaster1} ${kube}                                         \
|                                                                       \
sudo tee --append ${file}                                               ;
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
while true                                                              ;
do                                                                      \
        grep                                                            \
                "${success}"                                            \
                ${log}                                                  \
        &&                                                              \
        break                                                           ;
        sudo                                                            \
                kubeadm init                                            \
                        --config                                        \
                                ${config}                               \
                        --ignore-preflight-errors                       \
                                all                                     \
                        --upload-certs                                  \
                                                                        ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
rm --force ${config}                                                    ;
#########################################################################
sudo kubectl apply                                                      \
        --filename                                                      \
                ${calico}                                               \
        --kubeconfig                                                    \
                ${kubeconfig}                                           \
                                                                        ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo                                                            \
                kubectl                                                 \
                        --kubeconfig                                    \
                                ${kubeconfig}                           \
                        get                                             \
                                no                                      \
        |                                                               \
        grep Ready                                                      \
        |                                                               \
        grep --invert-match NotReady                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
