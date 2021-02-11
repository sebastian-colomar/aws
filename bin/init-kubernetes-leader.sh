#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${calico}"             || exit 100                             ;
test -n "${engine}"             || exit 101                             ;
test -n "${ip_leader}"          || exit 102                             ;
test -n "${kube}"               || exit 103                             ;
test -n "${pod_network_cidr}"   || exit 104                             ;
#########################################################################
kubeconfig=/etc/kubernetes/admin.conf                                   ;
sleep=10                                                                ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status ${engine}                                      \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
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
echo ${ip_leader} ${kube}                                               \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
sudo swapoff --all                                                      ;
sudo kubeadm init                                                       \
        --upload-certs                                                  \
        --control-plane-endpoint                                        \
                "${kube}"                                               \
        --pod-network-cidr                                              \
                ${pod_network_cidr}                                     \
        --ignore-preflight-errors                                       \
                all                                                     ;
#########################################################################
sudo kubectl apply                                                      \
        --filename                                                      \
                ${calico}                                               \
        --kubeconfig                                                    \
                ${kubeconfig}                                           \
                                                                        ;
#########################################################################
mkdir -p ${HOME}/.kube                                                  ;
sudo cp /etc/kubernetes/admin.conf ${HOME}/.kube/config                 ;
sudo chown -R $( id -u ):$( id -g ) ${HOME}/.kube/                      ;
echo 'source 0<( kubectl completion bash )'                             \
|                                                                       \
tee --append ${HOME}/.bashrc                                            ;
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
