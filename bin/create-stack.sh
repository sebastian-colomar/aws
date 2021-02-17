#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
test -n "${engine}"				|| exit 101		;
test -n "${os}"					|| exit 102		;
test -n "${template}"				|| exit 104		;
test -n "${version_major}"			|| exit 105		;
test -n "${version_minor}"			|| exit 106		;
#########################################################################
location=etc/cloudformation/${template}.yaml				;
stack=${os}-${engine}-${version_major}-${version_minor}			;
#########################################################################
export stack=${stack}-$( date +%s | rev | cut -c1,2 )			;
#########################################################################
aws 									\
	cloudformation 							\
		create-stack 						\
			--capabilities 					\
				CAPABILITY_NAMED_IAM 			\
			--parameters 					\
		ParameterKey=RecordSetName,ParameterValue=${stack} 	\
			--stack-name 					\
				${stack} 				\
			--template-body 				\
				file://${location} 			\
									;
#########################################################################
