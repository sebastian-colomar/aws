#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${engine}"		|| exit 100                             ;
#########################################################################
sleep=10                                                                ;
version="1.18.14-00"                                                    ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status ${engine}                                      \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg           \
|                                                                       \
sudo apt-key add -                                                      ;
echo deb http://apt.kubernetes.io/ kubernetes-xenial main               \
|                                                                       \
sudo tee -a /etc/apt/sources.list.d/kubernetes.list                     ;
sudo apt-get update                                                     ;
sudo apt-get install -y --allow-downgrades                              \
        kubeadm=${version}                                              \
        kubectl=${version}                                              \
        kubelet=${version}                                              \
                                                                        ;
sudo systemctl enable --now kubelet                                     ;
#########################################################################
