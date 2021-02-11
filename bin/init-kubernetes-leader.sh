#!/bin/bash -x
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
kubeconfig=/etc/kubernetes/admin.conf                                   ;
sleep=10                                                                ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo systemctl is-enabled kubelet                               \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
echo ${InstanceMaster1} ${kube}                                         \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
sudo swapoff --all                                                      ;
#########################################################################
success='^Your Kubernetes control-plane has initialized successfully'   ;
while true                                                              ;
do                                                                      \
        sudo kubeadm init                                               \
                --upload-certs                                          \
                --control-plane-endpoint                                \
                        "${kube}"                                       \
                --pod-network-cidr                                      \
                        ${pod_network_cidr}                             \
                --ignore-preflight-errors                               \
                        all                                             \
                                                                        ;
        grep                                                            \
                "${success}"                                            \
                ${log}                                                  \
        &&                                                              \
        break                                                           ;
        echo 'cgroupDriver: systemd'                                    \
        |                                                               \
        sudo tee --append /var/lib/kubelet/config.yaml                  ;
        sudo systemctl restart kubelet                                  ;
done                                                                    ;
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
        break                                                           \
                                                                        ;
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
