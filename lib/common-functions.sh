#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
function _encode_string {						\
                                                                        #
  local string="$1"							;
  echo -n ${string}                                                 	\
  |     	                                                        \
  sed 's/\\/ /'                                           		\
  |                                                       		\
  base64                                          			\
    --wrap 0                                				\
									;
}									;
#########################################################################
function _exec_remote_file {						\
                                                                        #
  local branch=$1							;
  local file=$2								;
  local path=$3								;
  local url=$4								;
                                                                        #
  local uuid=$( uuidgen )						;
  path=${uuid}/${path}                                                  ;
                                                                        #
  git clone                                                             \
        --single-branch --branch ${branch}				\
	https://${url}		                                        \
        ${uuid}                                                         \
									;
  chmod +x ./${path}/${file}						;
  ./${path}/${file}							;
  rm --force --recursive ${uuid}                                        ;
                                                                        #
}									;
#########################################################################
function _send_command {						\
                                                                        #
  local command="$1" 							;
  local stack="$2" 							;
  local target="$3" 							;
                                                                        #
  aws ssm send-command 							\
    --document-name "AWS-RunShellScript" 				\
    --output text 							\
    --parameters commands="${command}" 					\
    --query "Command.CommandId" 					\
    --targets 								\
      Key=tag:"aws:cloudformation:stack-name",Values="${stack}"		\
      Key=tag:"aws:cloudformation:logical-id",Values="${target}" 	\
   									;
}									;
#########################################################################
function _send_list_command {						\
                                                                        #
  local command="$1" 							;
  local sleep=$2							;
  local stack=$3 							;
  local target=$4 							;
                                                                        #
  local CommandId=$( 							\
    _send_command "${command}" ${stack} ${target}			\
  ) 									;
                                                                        #
  while true 								;
  do									\
    sleep ${sleep}							;
    aws ssm list-command-invocations 					\
      --command-id ${CommandId} 					\
      --details 							\
      --output text 							\
      --query "CommandInvocations[].CommandPlugins[].Output" 		\
    | 									\
    grep [a-zA-Z0-9] && break						;
  done 									;
                                                                        #
}									;
#########################################################################
function _send_list_command_remote {					\
                                                                        #
  local branch=$1
  local export="$2"							;
  local file=$3								;
  local path=$4								;
  local sleep=$5							;
  local stack=$6							;
  local targets="$7"							;
  local url=$8								;
                                                                        #
  local uuid=$( uuidgen )						;
  path=${uuid}/${path}                                                  ;
                                                                        #
  local command=" 							\
    ${export} 								\
    && 									\
    path=${path} 							\
    && 									\
    git clone 								\
      --single-branch --branch ${branch} 				\
      https://${url} 							\
      ${uuid} 								\
    && 									\
    chmod +x ./${path}/${file} 						\
    ./${path}/${file} 							\
      2>& 1 								\
    | 									\
    tee /tmp/${file}.log 						\
    && 									\
    rm --force --recursive ${uuid} 					\
  "									;
                                                                        #
  for target in ${targets}                                              ;
  do 									\
    _send_list_command "${command}" ${sleep} ${stack} ${target}		;
  done                                                                  ;
                                                                        #
}									;
#########################################################################
function _send_list_command_targets { 					\
  local command="$1"							;
  local sleep=$2							;
  local stack=$3							;
  local targets="$4"							;
  for target in ${targets}                                              ;
  do 									\
    _send_list_command "${command}" ${sleep} ${stack} ${target}		;
  done                                                                  ;
}									;
#########################################################################
function _send_list_command_targets_wait { 				\
                                                                        #
  local command="$1"							;
  local sleep=$2							;
  local stack=$3							;
  local targets="$4"							;
                                                                        #
  for target in ${targets}                                              ;
  do 									\
    while true								;
    do 									\
      output="$( _send_list_command "${command}" ${sleep} ${stack} ${target} )"	;
      echo "${output}" | grep ERROR && continue				;
      echo "${output}" | grep [a-zA-Z0-9] && break			;
    done								;
  done                                                                  ;
                                                                        #
}									;
#########################################################################
function _wait_service_targets { 					\
                                                                        #
  local service=$1							;
  local sleep=$2							;
  local stack=$3							;
  local targets="$4"							;
                                                                        #
  local command=" 							\
    service ${service} status 2> /dev/null | grep running 		\
  "                                                                     ;
                                                                        #
  _send_list_command_targets_wait "${command}" ${sleep} ${stack} "${targets}"   ;
                                                                        #
}									;
#########################################################################
