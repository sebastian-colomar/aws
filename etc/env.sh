# Choose your container engine
export engine=docker
export engine=containerd
export engine=cri-o

# Choose the domain name
export HostedZoneName=sebastian-colomar.es
export HostedZoneName=sebastian-colomar.com

# Choose the orchestrator
export mode=swarm
export mode=kubernetes

# Choose the operating system
export os=ubuntu18
export os=rhel8

# Choose the major version for the orchestrator
export version_major=18
export version_major=19
export version_major=20

# Choose the minor version for the orchestrator
export version_minor=14-00
export version_minor=7-00
export version_minor=2-00

# Choose the AWS cloudformation template
export template=${os}-mumbai-3masters-3workers-https

# This will export the location of the selected template
export location=etc/aws/${template}.yaml

# This will export a unique value for the AWS cloudformation stack
export stack=${os}-${engine}-${version_major}-${version_minor}-$( date +%s | rev | cut -c1,2 )
