# aws

```bash

export engine=docker
export engine=containerd
export engine=cri-o

export HostedZoneName=sebastian-colomar.com
export mode=kubernetes

export os=ubuntu18
export os=rhel8

export version_major=18
export version_minor=14-00

export version_major=19
export version_minor=7-00

export version_major=20
export version_minor=2-00

export template=${os}-mumbai-3masters-3workers-https

export location=etc/aws/${template}.yaml
export stack=${os}-${engine}-${version_major}-${version_minor}-$( date +%s | rev | cut -c1,2 )

aws cloudformation create-stack --stack-name ${stack} --template-body file://${location} --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=RecordSetName,ParameterValue=${stack}

chmod +x ./bin/init-orchestrator-masters.sh
nohup ./bin/init-orchestrator-masters.sh &

chmod +x ./bin/init-orchestrator-workers.sh
nohup ./bin/init-orchestrator-workers.sh &

```
