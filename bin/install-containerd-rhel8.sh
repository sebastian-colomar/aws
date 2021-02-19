#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
command=yum                                                             ;
engine=containerd                                                       ;
repo=https://download.docker.com/linux/centos/docker-ce.repo		;
#########################################################################
sudo tee /etc/modules-load.d/${engine}.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay							;
sudo modprobe br_netfilter						;
#########################################################################
sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system							;
#########################################################################
sudo ${command} update -y                                               ;
sudo ${command} install -y yum-utils device-mapper-persistent-data lvm2	;
sudo ${command}-config-manager --add-repo ${repo}                       ;
#########################################################################
sudo ${command} update -y                                               ;
#########################################################################
for package in                                                          \
        ${engine}.io                                                    \
                                                                        ;
do                                                                      \
        while true                                                      ;
        do                                                              \
                ${command} list                                         \
                        installed                                       \
                        ${package}                                      \
                &&                                                      \
                break                                                   ;
                sudo ${command} install -y                              \
                        ${package                                       \
                                                                        ;
                sleep ${sleep}                                          ;
        done                                                            ;
done                                                                    ;
#########################################################################
sudo mkdir -p /etc/${engine}						;
sudo mkdir -p /etc/systemd/system/${engine}.service.d                   ;
#########################################################################
${engine} config default | sudo tee /etc/${engine}/config.toml          ;
#########################################################################
sudo systemctl restart ${engine}					;
sudo systemctl enable --now ${engine}					;
#########################################################################
