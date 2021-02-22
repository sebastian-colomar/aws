#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x									;
#########################################################################
test -n "${branch}"		|| exit 101                             ;
test -n "${calico}"		|| exit 102                             ;
test -n "${domain}"		|| exit 103                             ;
test -n "${engine}"		|| exit 104                             ;
test -n "${kube}"		|| exit 105                             ;
test -n "${mode}"		|| exit 106                             ;
test -n "${os}"			|| exit 107				;
test -n "${path}"		|| exit 108                             ;
test -n "${port}"		|| exit 109                             ;
test -n "${repository}"		|| exit 110                             ;
test -n "${stack}"		|| exit 111                             ;
test -n "${username}"		|| exit 112                             ;
test -n "${version_major}"	|| exit 113                             ;
test -n "${version_minor}"	|| exit 114                             ;
#########################################################################
function __send_list_command_remote { 					\
	_send_list_command_remote                                       \
		${branch}                                               \
		"${export}"                                             \
		${file}                                                 \
		${log}                                                  \
		${path}                                                 \
		${sleep}                                                \
		${stack}                                                \
		"${targets}"                                            \
		${url}                                                  \
                                                                        ;
}
#########################################################################
sleep=10								;
#########################################################################
url=${domain}/${username}/${repository}					;
#########################################################################
service=${engine}							;
targets="								\
	InstanceMaster1 						\
	InstanceMaster2 						\
	InstanceMaster3 						\
"									;
#########################################################################
file=install-${service}-${os}.sh					;
log=/tmp/${file}.log							;
#########################################################################
export=" 								\
	export version_major=${version_major} 				\
"									;
#########################################################################
__send_list_command_remote						;
#########################################################################

service=kubelet								;
targets="								\
	InstanceMaster1 						\
	InstanceMaster2 						\
	InstanceMaster3 						\
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
__send_list_command_remote						;
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
export=" 								\
	export calico=${calico} 					\
	&& 								\
	export InstanceMaster1=${InstanceMaster1} 			\
	&& 								\
	export kube=${kube} 						\
	&& 								\
	export log=${log} 						\
	&& 								\
	export pod_network_cidr=${pod_network_cidr} 			\
	&& 								\
	export port=${port} 						\
"									;
#########################################################################
__send_list_command_remote						;
#########################################################################
token=certificate-key							;
#########################################################################
command="								\
	grep --max-count 1						\
		${token} 						\
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
token=discovery-token-ca-cert-hash					;
#########################################################################
command="								\
	grep --max-count 1						\
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
	grep --max-count 1						\
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
role=master								;
targets="								\
	InstanceMaster2							\
	InstanceMaster3							\
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
	export token_certificate=${token_certificate} 			\
	&& 								\
	export token_discovery=${token_discovery} 			\
	&& 								\
	export token_token=${token_token} 				\
"									;
#########################################################################
__send_list_command_remote						;
#########################################################################
