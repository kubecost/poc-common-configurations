# Kubecost with Datadog integration

## Overview

This repository is designed to give you a solution to integrate Kubecost with Datadog. By default, Kubecost will emit cost allocation metrics (unaggregrated, unreconciled) in a Prometheus compatible format with cloud providers) via `/metrics` endpoint. This solution installs Kubecost with additional annotations in cost-model pods, which allows Datadog agent to look into the `/metrics` endpoint, map prometheus compatible metrics to the Datadog compatible metrics, then push the metrics to your Datadog account. 

---
## Usage

### Prerequisites
- Existing Datadog account.
- Datadog API key to install the Datadog agent.
- Datadog permissions to create dashboards
- Permission to access and deploy new workload on the Kubernetes cluster.
- kubectl, helm CLI, wget are installed.
---
### Instructions
#### Install Datadog agent:

You can install Datadog agent to start monitoring your Kubernetes cluster using your Datadog API key. In this set up, you need to enable these flags to allow Datadog agent collect the metrics from Kubecost's cost-model container: `datadog. prometheusScrape.enabled='true'` & `datadog. prometheusScrape.serviceEndpoints=true'`. Using the following commands to install Datadog agent 

```bash
export DATADOG_API_KEY="<YOUR_API_KEY>"
helm upgrade -i datadog-agent --set datadog.site='us5.datadoghq.com' --set datadog.apiKey=$DATADOG_API_KEY datadog/datadog \
datadog. prometheusScrape.enabled=‘true’ \
datadog. prometheusScrape.serviceEndpoints=‘true’
```

#### Install Kubecost

*Step 1*: download `datadog-values.yaml` from this repository. This is the custom config that includes additional annotations allows Datadog agent to extract, transform and load raw cost allocation metrics into your Datadog account.

```bash
wget https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/datadog/datadog-values.yaml
```

*Step 2* Install Kubecost using the following command:

```bash
helm upgrade --install kubecost --namespace kubecost --create-namespace \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  -f datadog-values.yaml
  --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98"
```

Allow 3-5 minutes to have Kubecost installation completed and the metrics are pushed into your Datadog account. You can verify if the metrics are available by using [Datadog Metrics explorer](https://docs.datadoghq.com/metrics/explorer/) and looking for metrics starting with `kubecost.*`

#### Import Kubecost Dashboard

Once you can verify Kubecost metrics are pushed into your Datadog account successfully, you can download our example Datadog's dashboard `Kubecostdashboard.json` and import it into your Datadog account to visualize the cost allocation data.

```bash
wget https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/datadog/Kubecostdashboard.json
```

Check this [Datadog documentation ](https://docs.datadoghq.com/dashboards/#copy-import-or-export-dashboard-json)to learn how to import dashboard JSON.