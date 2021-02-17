# aws

Prepare the following configuration file and source it: env.sh (etc/aws/env.sh)
```bash
source etc/aws/env.sh
```
```
# WAIT UNTIL THE DEPLOYMENT IS STABLE BEFORE PROCEEDING FURTHER

chmod +x ./bin/init-orchestrator-masters.sh
nohup ./bin/init-orchestrator-masters.sh &
# WAIT UNTIL THE DEPLOYMENT IS STABLE BEFORE PROCEEDING FURTHER

chmod +x ./bin/init-orchestrator-workers.sh
nohup ./bin/init-orchestrator-workers.sh &

```
