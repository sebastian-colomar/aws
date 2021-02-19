#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
command=apt                                                             ;
engine=docker                                                           ;
sleep=10                                                                ;
#########################################################################
sudo {command} update -y                                                ;
#########################################################################
for package in                                                          \
        {engine}.io                                                     \
                                                                        ;
do                                                                      \
        while true                                                      ;
        do                                                              \
                ${command} list                                         \
                        --installed                                     \
                        ${package}                                      \
                &&                                                      \
                break                                                   ;
                sudo ${command} install -y                              \
                        --allow-downgrades                              \
                        ${package}                                      \
                                                                        ;
                sleep ${sleep}                                          ;
        done                                                            ;
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
  "storage-driver": "overlay2"
}
EOF
#########################################################################
sudo systemctl daemon-reload                                            ;
sudo systemctl restart ${engine}					;
sudo systemctl enable --now ${engine}					;
#########################################################################
