#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x									;
#########################################################################
test -n "${branch}"		|| exit 101                             ;
test -n "${domain}"		|| exit 103                             ;
test -n "${engine}"		|| exit 104                             ;
test -n "${kube}"		|| exit 105                             ;
test -n "${mode}"		|| exit 106                             ;
test -n "${os}"			|| exit 107				;
test -n "${path}"		|| exit 108                             ;
test -n "${repository}"		|| exit 109                             ;
test -n "${stack}"		|| exit 110                             ;
test -n "${username}"		|| exit 111                             ;
test -n "${version_major}"	|| exit 112                             ;
test -n "${version_minor}"	|| exit 113                             ;
#########################################################################
sleep=10								;
#########################################################################
url=${domain}/${username}/${repository}					;
#########################################################################
service=${engine}							;
targets="								\
	InstanceWorker1 						\
	InstanceWorker2 						\
	InstanceWorker3 						\
"									;
#########################################################################
file=install-${service}-${os}.sh					;
log=/tmp/${file}.log							;
#########################################################################
export=" 								\
	export version_major=${version_major} 				\
"									;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${log} 								\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
service=kubelet								;
targets="								\
	InstanceWorker1 						\
	InstanceWorker2 						\
	InstanceWorker3 						\
"									;
#########################################################################
file=install-${service}-${os}.sh					;
log=/tmp/${file}.log							;
#########################################################################
export=" 								\
	export engine=${engine} 					\
	&& 								\
	export version_major=${version_major} 				\
	&& 								\
	export version_minor=${version_minor} 				\
"									;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${log} 								\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
for instance in 							\
	InstanceMaster1 						\
	InstanceMaster2 						\
	InstanceMaster3 						\
									;
do 									\
	eval ${instance}="$( 						\
		aws ec2 describe-instances 				\
			--filters 					\
	Name=tag:"aws:cloudformation:stack-name",Values="${stack}" 	\
	Name=tag:"aws:cloudformation:logical-id",Values="${instance}" 	\
			--query 					\
			Reservations[].Instances[].PrivateIpAddress 	\
			--output 					\
				text 					\
	)"								;
done									;
#########################################################################
role=leader								;
targets="								\
	InstanceMaster1							\
"									;
#########################################################################
file=init-${mode}-${role}.sh						;
log=/tmp/${file}.log							;
#########################################################################
token=discovery-token-ca-cert-hash					;
#########################################################################
command="								\
	grep --max-count 1 						\
		${token} 						\
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
token=kubeadm.*join							;
#########################################################################
command="								\
	grep --max-count 1 						\
		${token} 						\
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
role=worker								;
targets="								\
	InstanceWorker1							\
	InstanceWorker2							\
	InstanceWorker3							\
"									;
#########################################################################
file=init-${mode}-${role}.sh						;
log=/tmp/${file}.log							;
#########################################################################
export=" 								\
	export InstanceMaster1=${InstanceMaster1} 			\
	&& 								\
	export kube=${kube} 						\
	&& 								\
	export log=${log} 						\
	&& 								\
	export token_discovery=${token_discovery} 			\
	&& 								\
	export token_token=${token_token} 				\
"									;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${log} 								\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
service=docker								;
targets=" 								\
	InstanceWorker1 						\
	InstanceWorker2 						\
	InstanceWorker3 						\
"									;
#########################################################################
file=install-${service}-${os}.sh					;
log=/tmp/${file}.log							;
#########################################################################
export=" 								\
  export engine=${engine}						\
"									;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${log} 								\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
service=kube-lb								;
targets=" 								\
	InstanceWorker1 						\
	InstanceWorker2 						\
	InstanceWorker3 						\
"									;
#########################################################################
file=install-${service}.sh						;
log=/tmp/${file}.log							;
#########################################################################
export=" 								\
	export InstanceMaster1=${InstanceMaster1} 			\
	&& 								\
	export InstanceMaster2=${InstanceMaster2} 			\
	&& 								\
	export InstanceMaster3=${InstanceMaster3} 			\
	&& 								\
	export kube=${kube} 						\
"									;
#########################################################################
_send_list_command_remote 						\
	${branch} 							\
	"${export}" 							\
	${file} 							\
	${log} 								\
	${path} 							\
	${sleep} 							\
	${stack} 							\
	"${targets}" 							\
	${url} 								\
									;
#########################################################################
