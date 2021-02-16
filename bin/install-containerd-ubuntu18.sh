#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
engine=containerd                                                       ;
#########################################################################
sudo apt-get update                                                     ;
sudo apt-get install -y ${engine}                                       ;
#########################################################################
sudo mkdir -p /etc/${engine}						;
sudo mkdir -p /etc/systemd/system/${engine}.service.d                   ;
containerd config default | sudo tee /etc/containerd/config.toml	;
#########################################################################
sudo systemctl restart ${engine}					;
sudo systemctl enable --now ${engine}					;
#########################################################################
