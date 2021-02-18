# How to set up a Kubernetes or Swarm cluster in AWS

Download the repository in a terminal with AWS credentials already configured:
```bash
git clone https://github.com/academiaonline/aws && cd aws
```
Edit the [common configuration file](etc/env.conf) and source it:
```bash
source etc/env.conf
```
Edit the [Kubernetes configuration file](etc/kubernetes.conf) and source it in the Leader instance:
```bash
source etc/kubernetes.conf
```
Edit the [AWS configuration file](etc/aws.conf) and source it:
```bash
source etc/aws.conf
```
Edit the [AWS cloudformation file](etc/cloudformation/infra-3masters-3workers-https.yaml) according to your needs and create the stack with the following [script](bin/create-stack.sh):
```bash
source bin/create-stack.sh
```
Try to connect to any instance to confirm that the deployment of the stack is complete.

WAIT UNTIL THE DEPLOYMENT IS STABLE BEFORE PROCEEDING ANY FURTHER

Initialize the orchestrator in the masters running this [script](bin/init-orchestrator-masters.sh):
```bash
script=bin/init-orchestrator-masters.sh
chmod +x ${script}
nohup ${script} &
tail -f nohup.out
```
Open a terminal in the Leader instance and check the logs:
```bash
tail -f /tmp/init-kubernetes-leader.sh.log
```
Open a terminal in both Master instances and check the logs:
```bash
tail -f /tmp/init-kubernetes-master.sh.log
```
Check that the control plane has been successfully initialized running this command from any master instance:
```bash
watch sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get no
```
WAIT UNTIL THE DEPLOYMENT IS STABLE BEFORE PROCEEDING ANY FURTHER

Connect the workers to the cluster running this [script](bin/init-orchestrator-workers.sh):
```bash
script=bin/init-orchestrator-workers.sh
chmod +x ${script}
nohup ${script} &
tail -f nohup.out
```
Open a terminal in all the worker instances and check the logs:
```bash
tail -f /tmp/init-kubernetes-worker.sh.log
```
Check that the worker nodes have correctly joined the cluster running this command from any master instance:
```bash
watch sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get no
```
# How to manually set up a Kubernetes cluster

## First configure the Master instances
Download the repository in all the master instances:
```bash
git clone https://github.com/academiaonline/aws && cd aws
```
Edit the [common configuration file](etc/env.conf) and source it in all the master instances:
```bash
source etc/env.conf
```
Edit the [repository configuration file](etc/repo.conf) and source it in all the master instances:
```bash
source etc/repo.conf
```
Edit the [Kubernetes configuration file](etc/kubernetes.conf) and source it in all the master instances:
```bash
source etc/kubernetes.conf
```
Install the container engine in all the master instances:
```bash
service=${engine}
file=install-${service}-${os}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Install the kubelet in all the master instances:
```bash
service=kubelet
file=install-${service}-${os}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Initialize the Kubernetes cluster in the leader instance:
```bash
InstanceMaster1=$( ip route | awk /kernel/'{ print $9 }' )
role=leader
file=init-${mode}-${role}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Retrieve the certificate token from the log file in the leader instance:
```bash
token=certificate-key
command=" grep --max-count 1 ${token} ${log} " && string="$( while true ; do output="$( ${command} )" ; echo "${output}" | grep -q ERROR && continue ; echo "${output}" | grep [a-zA-Z0-9] && break ; done ; )"
token_certificate=$( echo -n "${string}" | sed 's/\\/ /' | base64 --wrap 0 )
```
Retrieve the discovery token from the log file in the leader instance:
```bash
token=discovery-token-ca-cert-hash
command=" grep --max-count 1 ${token} ${log} " && string="$( while true ; do output="$( ${command} )" ; echo "${output}" | grep -q ERROR && continue ; echo "${output}" | grep [a-zA-Z0-9] && break ; done ; )"
token_discovery=$( echo -n "${string}" | sed 's/\\/ /' | base64 --wrap 0 )
```
Retrieve the token join command from the log file in the leader instance:
```bash
token=kubeadm.*join
command=" grep --max-count 1 ${token} ${log} " && string="$( while true ; do output="$( ${command} )" ; echo "${output}" | grep -q ERROR && continue ; echo "${output}" | grep [a-zA-Z0-9] && break ; done ; )"
token_token=$( echo -n "${string}" | sed 's/\\/ /' | base64 --wrap 0 )
```
Echo the necessary parameters that have been retrieved from the leader instance:
```bash
echo InstanceMaster1=${InstanceMaster1}
echo token_certificate=${token_certificate}
echo token_discovery=${token_discovery}
echo token_token=${token_token}
```
Export those parameters in all the master instances:
```bash
InstanceMaster1=${InstanceMaster1}
token_certificate=${token_certificate}
token_discovery=${token_discovery}
token_token=${token_token}
```
Join the Kubernetes control plane from all the master instances:
```bash
role=master
file=init-${mode}-${role}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Run the following command from the leader instance in order to monitor the control plane:
```bash
watch sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get no
```
Wait until all the master instances have joined the Kubernetes control plane.
## Then configure the Worker instances

Download the repository in all the worker instances:
```bash
git clone https://github.com/academiaonline/aws && cd aws
```
Edit the [common configuration file](etc/env.conf) and source it in all the worker instances:
```bash
source etc/env.conf
```
Edit the [repository configuration file](etc/repo.conf) and source it in all the worker instances:
```bash
source etc/repo.conf
```
Edit the [Kubernetes configuration file](etc/kubernetes.conf) and source it in all the worker instances:
```bash
source etc/kubernetes.conf
```
Install the container engine in all the worker instances:
```bash
service=${engine}
file=install-${service}-${os}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Install the kubelet in all the worker instances:
```bash
service=kubelet
file=install-${service}-${os}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Echo the necessary parameters that have been retrieved from the leader instance:
```bash
echo InstanceMaster1=${InstanceMaster1}
echo token_certificate=${token_certificate}
echo token_discovery=${token_discovery}
echo token_token=${token_token}
```
Export those parameters in all the worker instances:
```bash
InstanceMaster1=${InstanceMaster1}
token_certificate=${token_certificate}
token_discovery=${token_discovery}
token_token=${token_token}
```
Join the Kubernetes data plane from all the worker instances:
```bash
role=worker
file=init-${mode}-${role}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Install the docker engine in all the worker instances:
```bash
service=docker
file=install-${service}-${os}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```
Install the load balancer for the Kubernetes API server in all the worker instances:
```bash
service=kube-lb
file=install-${service}.sh
log=/tmp/${file}.log && source ${path}/${file} 2>& 1 | tee --append ${log}
```


