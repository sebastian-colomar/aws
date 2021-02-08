#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set +x && test "$debug" = true && set -x				;
#########################################################################
test -n "$A"	                && export A                 || exit 301 ;
test -n "$branch_docker_aws"	&& export branch_docker_aws || exit 302 ;
test -n "$debug" 		&& export debug	            || exit 303	;
test -n "$domain" 		&& export domain	    || exit 304	;
test -n "$HostedZoneName"	&& export HostedZoneName    || exit 305 ;
test -n "$RecordSetNameKube"	&& export RecordSetNameKube || exit 306 ;
test -n "$mode"                 && export mode	            || exit 307	;
test -n "$stack"                && export stack	            || exit 308	;
#########################################################################
file=common-functions.sh						;
path=lib                                 				;
#########################################################################
source ./$path/$file                                                    ;
#########################################################################
export -f encode_string							;
export -f exec_remote_file						;
export -f send_command							;
export -f send_list_command						;
export -f send_remote_file						;
export -f send_wait_targets						;
export -f service_wait_targets						;
#########################################################################
file=init-$mode.sh					    	  ;
path=bin								;
#########################################################################
./$path/$file                                                           ;
#########################################################################
