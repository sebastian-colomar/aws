#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${calico}"             || exit 100                             ;
test -n "${engine}"             || exit 101                             ;
test -n "${kube}"               || exit 102                             ;
test -n "${InstanceMaster1}"    || exit 103                             ;
test -n "${log}"                || exit 104                             ;
test -n "${pod_network_cidr}"   || exit 105                             ;
#########################################################################
kubeconfig=/etc/kubernetes/admin.conf                                   ;
sleep=10                                                                ;
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
echo ${InstanceMaster1} ${kube}                                         \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
sudo swapoff --all                                                      ;
#########################################################################
config=/tmp/$( uuidgen ).yaml                                           ;
sudo tee ${config} 0<<EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cgroup-driver: "systemd"
---
apiVersion: kubeadm.k8s.io/v1beta2
controlPlaneEndpoint: "${kube}:6443"
kind: ClusterConfiguration
networking:
  podSubnet: ${pod_network_cidr}
---
EOF
#########################################################################
test ${engine} = cri-o                                                  \
&&                                                                      \
newline="  criSocket: /var/run/crio/crio.sock"                          \
&&                                                                      \
sed --in-place "/^nodeRegistration:/s/$/${newline}/" ${config}          \
                                                                        ;
#########################################################################
success='^Your Kubernetes control-plane has initialized successfully'   ;
while true                                                              ;
do                                                                      \
        sudo kubeadm init                                               \
                --config                                                \
                        ${config}                                       \
                --ignore-preflight-errors                               \
                        all                                             \
                --upload-certs                                          \
                                                                        ;
        grep                                                            \
                "${success}"                                            \
                ${log}                                                  \
        &&                                                              \
        break                                                           ;
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
        kubectl get no                                                  \
        --kubeconfig                                                    \
                ${kubeconfig}                                           \
        |                                                               \
        grep Ready                                                      \
        |                                                               \
        grep --invert-match NotReady                                    \
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
