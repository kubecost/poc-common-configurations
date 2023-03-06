# Kubecost with Datadog integration

## Overview
This repository is designed to give you a solution to integrate Kubecost with Datadog. By default, Kubecost will emit cost allocation metrics (unaggregated, unreconciled) in a Prometheus-compatible format with cloud providers) via `/metrics` endpoint. This solution installs Kubecost with additional annotations in cost-model pods, which allows the Datadog agent to look into the `/metrics` endpoint, map Prometheus-compatible metrics to the Datadog-compatible metrics, then push the metrics to your Datadog account.

---

## Caveats

Note that the only method to get accurate costs (reconciled with cloud provider billing) is to use the Kubecost API. Kubecost's `/metrics` endpoint contains real-time metrics that can only estimate costs using custom pricing or onDemand cloud provider rates.

The primary purpose of the dashboards provided is to allow visibility into the metrics used by Kubecost to create the cost-model.

---

## Usage

### Prerequisites
- Existing Datadog account.
- Datadog API key to install the Datadog agent.
- Datadog permissions to create dashboards
- Permission to access and deploy new workload on the Kubernetes cluster.
- kubectl, helm CLI, wget are installed.

### Instructions
#### Install Datadog agent:

You can install the Datadog agent to start monitoring your Kubernetes cluster using your Datadog API key. In this setup, you need to enable these flags to allow the Datadog agent to collect the metrics from Kubecost's cost-model container: `datadog. prometheusScrape.enabled='true'` & `datadog. prometheusScrape.serviceEndpoints=true'`. Using the following commands to install the Datadog agent 

```bash
export DATADOG_API_KEY="<YOUR_API_KEY>"
helm upgrade -i datadog-agent --set datadog.site='us5.datadoghq.com' --set datadog.apiKey=$DATADOG_API_KEY datadog/datadog \
datadog. prometheusScrape.enabled=‘true’ \
datadog. prometheusScrape.serviceEndpoints=‘true’
```

#### Install Kubecost

*Step 1*: download `datadog-values.yaml` from this repository. This file contains the custom configs and additional annotations allowing Datadog agent to extract, transform and load raw cost allocation metrics into your Datadog account.

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

Allow 3-5 minutes to have the Kubecost installation completed, and the metrics are pushed into your Datadog account. You can verify if the metrics are available by using [Datadog Metrics explorer](https://docs.datadoghq.com/metrics/explorer/) and looking for metrics starting with `kubecost.*`

#### Import Kubecost Dashboard

Once you can successfully verify that Kubecost metrics are pushed into your Datadog account, you can download our example Datadog's dashboard `Kubecostdashboard.json` and import it into your Datadog account to visualize the cost allocation data.

```bash
wget https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/datadog/Kubecostdashboard.json
```

Check this [Datadog documentation ](https://docs.datadoghq.com/dashboards/#copy-import-or-export-dashboard-json)to learn how to import dashboard JSON.
