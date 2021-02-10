# aws

```bash
cluster=mumbai-3masters-3workers-https
engine=docker
HostedZoneName=sebastian-colomar.com
ip_leader=100.168.1.100
ip_master1=100.168.1.100
ip_master2=100.168.3.100
ip_master3=100.168.5.100
mode=kubernetes
os=ubuntu18

location=etc/aws/${cluster}.yaml
stack=${os}-${engine}-${cluster}-$( date +%s )

aws cloudformation create-stack --stack-name ${stack} --template-body file://${location} --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=RecordSetName,ParameterValue=kubernetes-${os}-${engine}

source ./bin/init-orchestrator.sh
```
