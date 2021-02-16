#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${log}"                || exit 100                             ;
#########################################################################
engine=docker                                                           ;
repo=https://download.docker.com/linux/centos/docker-ce.repo            ;
sleep=10                                                                ;
#########################################################################
sudo yum update -y                                                      ;
sudo yum install -y yum-utils device-mapper-persistent-data lvm2	;
sudo yum-config-manager --add-repo ${repo}				;
sudo yum update -y                                                      ;
#########################################################################
success='^Complete!'                                                    ;
while true                                                              ;
do                                                                      \
        sudo yum install -y ${engine}-ce                                \
                                                                        ;
        grep                                                            \
                "${success}"                                            \
                ${log}                                                  \
        &&                                                              \
        break                                                           ;
        sleep ${sleep}                                                  ;
done                                                                    ;
#########################################################################
sudo mkdir -p /etc/${engine}						;
sudo mkdir -p /etc/systemd/system/${engine}.service.d                   ;
#########################################################################
sudo tee /etc/${engine}/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
#########################################################################
sudo systemctl daemon-reload                                            ;
sudo systemctl restart ${engine}					;
sudo systemctl enable --now ${engine}					;
#########################################################################
