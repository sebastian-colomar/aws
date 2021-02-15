#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${version_major}"	|| exit 100                             ;
#########################################################################
engine=cri-o								;
OS=CentOS_8								;
path1=/kubic:/libcontainers:/stable					;
path2=kubic:libcontainers:stable					;
repo_path=/etc/yum.repos.d/devel:kubic:libcontainers			;
repo_url=https://download.opensuse.org/repositories/devel		;
sleep=10                                                                ;
#########################################################################
path3=${OS}/devel:kubic:libcontainers:stable				;
path4=${engine}:1.${version_major}					;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo systemctl is-enabled docker                                \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
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
sudo curl -L -o ${repo_path}:stable.repo				\
	${repo_url}:${path1}/${path3}.repo				;
sudo curl -L -o ${repo_path}:stable:${path4}.repo			\
	${repo_url}:${path2}:${path4}/${path3}:${path4}.repo		;
sudo yum update -y                                                      ;
sudo yum install -y ${engine}						;
sudo systemctl restart ${engine}					;
sudo systemctl enable --now ${engine}					;
#########################################################################
