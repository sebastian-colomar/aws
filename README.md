# aws

```bash
export template=ubuntu18-mumbai-3masters-3workers-https
export template=rhel8-mumbai-3masters-3workers-https
export engine=docker
export engine=containerd
export HostedZoneName=sebastian-colomar.com
export ip_master1=10.168.1.100
export ip_master2=10.168.3.100
export ip_master3=10.168.5.100
export mode=kubernetes
export os=ubuntu18
export os=rhel8

export ip_leader=${ip_master1}
export location=etc/aws/${template}.yaml
export stack=${os}-$( date +%s )

aws cloudformation create-stack --stack-name ${stack} --template-body file://${location} --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=RecordSetName,ParameterValue=${stack} ParameterKey=PrivateIpAddressInstanceMaster1,ParameterValue=${ip_master1} ParameterKey=PrivateIpAddressInstanceMaster2,ParameterValue=${ip_master2} ParameterKey=PrivateIpAddressInstanceMaster3,ParameterValue=${ip_master3} 

chmod +x ./bin/init-orchestrator.sh
nohup ./bin/init-orchestrator.sh &
```
