#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
ip_leader=$( ip r | grep -v docker | awk '/kernel/{ print $9 }' )       ;
kube=kube-apiserver                                                     ;
log=/tmp/install-leader.log                                             ;
sleep=10                                                                ;
#########################################################################
calico=https://docs.projectcalico.org/v3.17/manifests/calico.yaml       ;
pod_network_cidr=192.168.0.0/16                                         ;
kubeconfig=/etc/kubernetes/admin.conf                                   ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo systemctl is-enabled kubelet                               \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
echo $ip_leader $kube                                                   \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
sudo swapoff --all                                                      ;
sudo kubeadm init                                                       \
        --upload-certs                                                  \
        --control-plane-endpoint                                        \
                "$kube"                                                 \
        --pod-network-cidr                                              \
                $pod_network_cidr                                       \
        --ignore-preflight-errors                                       \
                all                                                     \
        2>&1                                                            \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
sudo kubectl apply                                                      \
        --filename                                                      \
                $calico                                                 \
        --kubeconfig                                                    \
                $kubeconfig                                             \
        2>&1                                                            \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
mkdir -p $HOME/.kube                                                    ;
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config                   ;
sudo chown -R $(id -u):$(id -g) $HOME/.kube/                            ;
echo 'source <(kubectl completion bash)'                                \
|                                                                       \
tee --append $HOME/.bashrc                                              ;
#########################################################################
while true                                                              ;
do                                                                      \
        kubectl get node                                                \
        |                                                               \
        grep Ready                                                      \
        |                                                               \
        grep --invert-match NotReady                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
sudo sed --in-place                                                     \
        /$kube/d                                                        \
        /etc/hosts                                                      ;
sudo sed --in-place                                                     \
        /127.0.0.1.*localhost/s/$/' '$kube/                             \
        /etc/hosts                                                      ;
#########################################################################
