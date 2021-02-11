#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${engine}"		|| exit 100                             ;
#########################################################################
OS=CentOS_8								;
repo_path=/etc/yum.repos.d/devel:kubic:libcontainers			;
repo_url=https://download.opensuse.org/repositories/devel		;
VERSION=1.18								;
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
	${repo_url}:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo	;
sudo curl -L -o ${repo_path}:stable:cri-o:$VERSION.repo			\
	${repo_url}:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo	;
sudo yum install -y ${engine}						;
sudo systemctl restart ${engine}					;
sudo systemctl enable --now ${engine}					;
#########################################################################
