#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x;
#########################################################################
test -n "${engine}"		|| exit 100                             ;
test -n "${file}"               || exit 101                             ;
test -n "${HostedZoneName}"	|| exit 102                             ;
test -n "${ip_leader}"          || exit 103                             ;
test -n "${stack}"		|| exit 104                             ;
#########################################################################
domain=github.com
username=academiaonline
repository=aws
branch=main

calico=https://docs.projectcalico.org/v3.17/manifests/calico.yaml       ;
pod_network_cidr=192.168.0.0/16                                         ;
#########################################################################
export=" 								\
"									;
RecordSetNameKube=kube-apiserver
kube=${RecordSetNameKube}.${HostedZoneName};
log=/tmp/${file}.log;
path=bin;
sleep=10;

#########################################################################
url=${domain}/${username}/${repository};
#########################################################################
export=" 								\
  ${export}								\
  && 									\
  export engine=${engine} 						\
"									;
targets="								\
	InstanceMaster1							\
	InstanceMaster2							\
	InstanceMaster3							\
	InstanceWorker1							\
	InstanceWorker2							\
	InstanceWorker3							\
"									;
#########################################################################
for service in ${engine} kubelet	;
	do \
		file=install-${service}-{os}.sh	;
		_send_list_command_remote ${branch} "" ${file} ${path} ${sleep} ${stack} "${targets}" ${url};
	done	;
#########################################################################
export=" 								\
"									;
export=" 								\
  $export								\
  && 									\
  export calico=${calico} 						\
  && 									\
  export ip_leader=${ip_leader}						\
  && 									\
  export kube=${kube}							\
  && 									\
  export pod_network_cidr=${pod_network_cidr} 				\
"									;
targets="								\
	InstanceMaster1							\
"									;
#########################################################################
role=leader
file=init-${mode}-${role}.sh;
_send_list_command_remote ${branch} "${export}" ${file} ${path} ${sleep} ${stack} "${targets}" ${url};
#########################################################################
command="								\
	grep --max-count 1						\
		certificate-key						\
		$log							\
"									;
token_certificate=$(							\
  encode_string "							\
    $(									\
      _send_list_command_targets_wait "$command" $sleep $stack "$targets" \
    )									\
  "									;	
)									;
#########################################################################
command="								\
	grep --max-count 1						\
		discovery-token-ca-cert-hash				\
		$log							\
"									;
token_discovery=$(							\
  encode_string "							\
    $(									\
      _send_list_command_targets_wait "$command" $sleep $stack "$targets" \
    )									\
  "									;	
)									;
#########################################################################
command="								\
	grep --max-count 1						\
		kubeadm.*join						\
		$log							\
"									;
token_token=$(								\
  encode_string "							\
    $(									\
      _send_list_command_targets_wait "$command" $sleep $stack "$targets" \
    )									\
  "									;	
)									;
#########################################################################
export=" 								\
"									;
export=" 								\
  $export								\
  &&									\
  export ip_leader=${ip_leader}						\
  && 									\
  export kube=${kube}							\
  && 									\
  export token_certificate=$token_certificate				\
  &&									\
  export token_discovery=$token_discovery				\
  &&									\
  export token_token=$token_token					\
"									;
role=master
file=init-${mode}-${role}.sh;
targets="								\
	InstanceMaster2							\
	InstanceMaster3							\
"									;
_send_list_command_remote ${branch} "${export}" ${file} ${path} ${sleep} ${stack} "${targets}" ${url};
#########################################################################
unset token_certificate							;
#########################################################################
export=" 								\
"									;
export=" 								\
  $export								\
  &&									\
  export ip_leader=${ip_leader}						\
  && 									\
  export kube=${kube}							\
  && 									\
  export token_certificate=$token_certificate				\
  &&									\
  export token_discovery=$token_discovery				\
  &&									\
  export token_token=$token_token					\
"									;
role=worker;
test ${engine} == docker && file=init-${mode}-${role}-${engine}.sh || file=init-${mode}-${role}.sh;
targets="								\
	InstanceWorker1							\
	InstanceWorker2							\
	InstanceWorker3							\
"									;
_send_list_command_remote ${branch} "${export}" ${file} ${path} ${sleep} ${stack} "${targets}" ${url};
#########################################################################
