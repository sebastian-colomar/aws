#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x									;
#########################################################################
test -n "${engine}"		|| exit 101                             ;
test -n "${HostedZoneName}"	|| exit 102                             ;
test -n "${ip_leader}"          || exit 103                             ;
test -n "${ip_master1}"		|| exit 104                             ;
test -n "${ip_master2}"		|| exit 105                             ;
test -n "${ip_master3}"		|| exit 106                             ;
test -n "${mode}"		|| exit 107                             ;
test -n "${os}"			|| exit 108                             ;
test -n "${stack}"		|| exit 109                             ;
#########################################################################
branch=main								;
calico=https://docs.projectcalico.org/v3.17/manifests/calico.yaml       ;
domain=github.com							;
path=bin								;
pod_network_cidr=192.168.0.0/16                                         ;
RecordSetNameKube=kube-apiserver					;
repository=aws								;
sleep=10								;
username=academiaonline							;
#########################################################################
kube=${RecordSetNameKube}.${HostedZoneName}				;
url=${domain}/${username}/${repository}					;
#########################################################################
export=" 								\
  export engine=${engine} 						\
"									;
targets=" 								\
	InstanceMaster1 						\
	InstanceMaster2 						\
	InstanceMaster3 						\
	InstanceWorker1 						\
	InstanceWorker2 						\
	InstanceWorker3 						\
"									;
#########################################################################
for service in ${engine} kubelet					;
	do 								\
		file=install-${service}-${os}.sh			;
		_send_list_command_remote 				\
			${branch} 					\
			"${export}" 					\
			${file} 					\
			${path} 					\
			${sleep} 					\
			${stack} 					\
			"${targets}" 					\
			${url} 						\
									&
	done								;
#########################################################################
export=" 								\
  export calico=${calico} 						\
  && 									\
  export ip_leader=${ip_leader}						\
  && 									\
  export kube=${kube}							\
  && 									\
  export pod_network_cidr=${pod_network_cidr} 				\
"									;
role=leader								;
targets="								\
	InstanceMaster1							\
"									;
#########################################################################
file=init-${mode}-${role}.sh						;
log=/tmp/${file}.log							;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
command="								\
	grep --max-count 1						\
		certificate-key						\
		${log}							\
"									;
token_certificate=$(							\
	_encode_string "						\
		$(							\
			_send_list_command_targets_wait 		\
				"${command}" 				\
				${sleep} 				\
				${stack} 				\
				"${targets}" 				\
		)							\
	"								;
)									;
#########################################################################
command="								\
	grep --max-count 1						\
		discovery-token-ca-cert-hash				\
		${log}							\
"									;
token_discovery=$(							\
	_encode_string "						\
		$(							\
			_send_list_command_targets_wait 		\
				"${command}" 				\
				${sleep} 				\
				${stack} 				\
				"${targets}" 				\
		)							\
	"								;
)									;
#########################################################################
command="								\
	grep --max-count 1						\
		kubeadm.*join						\
		${log}							\
"									;
token_token=$(								\
	_encode_string "						\
		$(							\
			_send_list_command_targets_wait 		\
				"${command}" 				\
				${sleep} 				\
				${stack} 				\
				"${targets}" 				\
		)							\
	"								;
)									;
#########################################################################
export=" 								\
  export ip_leader=${ip_leader}						\
  && 									\
  export kube=${kube}							\
  && 									\
  export token_certificate=${token_certificate}				\
  &&									\
  export token_discovery=${token_discovery}				\
  &&									\
  export token_token=${token_token}					\
"									;
role=master								;
targets="								\
	InstanceMaster2							\
	InstanceMaster3							\
"									;
#########################################################################
file=init-${mode}-${role}.sh						;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
export=" 								\
  export ip_master1=${ip_master1}					\
  && 									\
  export ip_master2=${ip_master2}					\
  && 									\
  export ip_master3=${ip_master3}					\
  && 									\
  export kube=${kube}							\
  && 									\
  export token_discovery=${token_discovery}				\
  &&									\
  export token_token=${token_token}					\
"									;
role=worker;
targets="								\
	InstanceWorker1							\
	InstanceWorker2							\
	InstanceWorker3							\
"									;
#########################################################################
test ${engine} == docker 						\
&& 									\
file=init-${mode}-${role}-${engine}.sh 					\
|| 									\
file=init-${mode}-${role}.sh						;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
