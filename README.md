# aws

```bash
template=ubuntu18-mumbai-3masters-3workers-https
engine=docker
HostedZoneName=sebastian-colomar.com
ip_master1=10.168.1.100
ip_master2=10.168.3.100
ip_master3=10.168.5.100
mode=kubernetes
os=ubuntu18

ip_leader=${ip_master1}
location=etc/aws/${template}.yaml
stack=${os}-${engine}-${template}-$( date +%s )

aws cloudformation create-stack --stack-name ${stack} --template-body file://${location} --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=RecordSetName,ParameterValue=${stack} ParameterKey=PrivateIpAddressInstanceMaster1,ParameterValue=${ip_master1} ParameterKey=PrivateIpAddressInstanceMaster2,ParameterValue=${ip_master2} ParameterKey=PrivateIpAddressInstanceMaster3,ParameterValue=${ip_master3} 

source ./bin/init-orchestrator.sh
```
