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
baseurl=https://packages.cloud.google.com				;
rpm_key=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg	;
sleep=10                                                                ;
yum_key=https://packages.cloud.google.com/yum/doc/yum-key.gpg		;
#########################################################################
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=${baseurl}/yum/repos/kubernetes-el7-\${basearch}
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=${yum_key} ${rpm_key}
exclude=kubelet kubeadm kubectl
EOF
#########################################################################
sudo setenforce 0							;
sudo sed -i /^SELINUX/s/enforcing/permissive/ /etc/selinux/config	;
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
sudo yum update -y                                                      ;
sudo yum install -y --disableexcludes=kubernetes                        \
        kubeadm-1.${version_major}.${version_minor}                     \
        kubectl-1.${version_major}.${version_minor}                     \
        kubelet-1.${version_major}.${version_minor}                     \
                                                                        ;
sudo systemctl enable --now kubelet                                     ;
#########################################################################
