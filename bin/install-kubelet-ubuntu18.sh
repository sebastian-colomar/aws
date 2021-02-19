#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${engine}"		|| exit 100                             ;
test -n "${version_major}"	|| exit 110                             ;
test -n "${version_minor}"	|| exit 111                             ;
#########################################################################
command=apt                                                             ;
sleep=10                                                                ;
#########################################################################
sudo sed --in-place /swap/d /etc/fstab                                  ;
sudo swapoff --all                                                      ;
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
#########################################################################
sudo ${command} update -y                                               ;
#########################################################################
for package in                                                          \
        kubeadm                                                         \
        kubectl                                                         \
        kubelet                                                         \
                                                                        ;
do                                                                      \
        while true                                                      ;
        do                                                              \
                ${command} list                                         \
                        --installed                                     \
                |                                                       \
                grep                                                    \
                        ${package}.*1.${version_major}.${version_minor} \
                &&                                                      \
                break                                                   ;
                sudo ${command} install -y                              \
                        --allow-downgrades                              \
                        ${package=1.${version_major}.${version_minor}   \
                                                                        ;
                sleep ${sleep}                                          ;
        done                                                            ;
done                                                                    ;
#########################################################################
sudo systemctl enable --now kubelet                                     ;
#########################################################################
