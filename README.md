# aws

Edit the [common configuration file](etc/env.conf) and source it:
```bash
source etc/env.conf
```
Edit the [AWS configuration file](etc/aws.conf) and source it:
```bash
source etc/aws.conf
```
Edit the [AWS cloudformation file](etc/aws/infra-3masters-3workers-https.yaml) according to your needs and create the stack:
```bash
source bin/create-stack.sh
```
WAIT UNTIL THE DEPLOYMENT IS STABLE BEFORE PROCEEDING FURTHER
```bash
chmod +x ./bin/init-orchestrator-masters.sh
nohup ./bin/init-orchestrator-masters.sh &
# WAIT UNTIL THE DEPLOYMENT IS STABLE BEFORE PROCEEDING FURTHER

chmod +x ./bin/init-orchestrator-workers.sh
nohup ./bin/init-orchestrator-workers.sh &

```
