#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x;
#########################################################################
domain=github.com
username=academiaonline
repository=kubernetes
#########################################################################
export=" 								\
"									;
kube=${RecordSetNameKube}.${HostedZoneName};
log=/tmp/init-${mode}.log;
path=${path};
sleep=10;
#########################################################################
url=${domain}/${username}/${repository};
#########################################################################
export=" 								\
  $export								\
  && 									\
  export branch=${branch} \
  && 									\
  export url=${url}							\
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
		_send_list_command_remote $branch "$export" $file $path $sleep $stack "$targets" $url	;
	done	;
#########################################################################
export=" 								\
  $export								\
  && 									\
  export ip_leader=$ip_leader						\
  && 									\
  export kube=$kube							\
  && 									\
  export log=$log							\
"									;
targets="								\
	InstanceMaster1							\
"									;
#########################################################################
file=init-kubernetes-leader.sh;
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
  $export								\
  &&									\
  export token_certificate=$token_certificate				\
  &&									\
  export token_discovery=$token_discovery				\
  &&									\
  export token_token=$token_token					\
"									;
file=cluster-kubernetes-manager.sh					;
targets="								\
	InstanceMaster2							\
	InstanceMaster3							\
"									;
_send_list_command_remote ${branch} "${export}" ${file} ${path} ${sleep} ${stack} "${targets}" ${url};
#########################################################################
unset token_certificate							;
#########################################################################
export=" 								\
  $export								\
"									;
file=cluster-kubernetes-worker.sh					;
targets="								\
	InstanceWorker1							\
	InstanceWorker2							\
	InstanceWorker3							\
"									;
_send_list_command_remote ${branch} "${export}" ${file} ${path} ${sleep} ${stack} "${targets}" ${url};
#########################################################################
