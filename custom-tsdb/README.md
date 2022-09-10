# Kubecost with existing multi-cluster aggregated metrics

Note that the most common support issue with Kubecost is due to misconfigured Prometheus. Kubecost has a turnkey solution for multi-cluster and the below configuration should only be used by advanced Kubernetes teams.

This repo is intended for use during a POC with assistance from the Solutions Engineering team.

It is recommended to run Kubecost with default settings during proof-of-concepts in order to reduce issues.

Before disabling Kubecost prometheus, multi-cluster metric aggregation must be reliable and include per-cluster labels.

 > Multi-cluster requires an enterprise subscription


## Installation

In addition to the settings below, each cluster must scrape the kubecost exporter (see extraScrapeConfigs.yaml). Negative idle costs are almost always a result of missing these metrics.

### Primary cluster install:

```sh
helm install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost --create-namespace -f values-primary.yaml
```

### Secondary clusters run a minimal footprint.

```sh
helm install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost --create-namespace -f values-secondary.yaml
```

### Cloud Cost Reconcillation

It is recommended to get Kubecost up and running before configuring cloud-integrations.

Without cloud-integrations, Kubecost will use public onDemand rates for each cloud provider. In order to reconcile the short-term onDemand costs with actual cloud billing, configure the following:

- [AWS cloud-integration](https://github.com/kubecost/docs/blob/main/aws-out-of-cluster.md)
- [Azure cloud-integration](https://github.com/kubecost/docs/blob/main/azure-out-of-cluster.md)
- [GCP cloud-integration](https://github.com/kubecost/docs/blob/main/gcp-out-of-cluster.md)

During a POC, these secrets can be entered in the Kubecost UI in the `Settings` page under `Cloud Cost Settings`.

Long-term, Kubecost recomends storing the configuration in `cloud-integraion.json` that is described in the respective folders in this repo.

- [AWS](../aws/)
- [Azure](../azure/)
- [GCP](../gcp/)
