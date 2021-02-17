# How to set up a Kubernetes or Swarm cluster in AWS:

Edit the [common configuration file](etc/env.conf) and source it:
```bash
source etc/env.conf
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
