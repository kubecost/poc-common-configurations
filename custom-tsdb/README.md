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
helm install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost --create-namespace -f values-secondary.yaml
```

### Secondary clusters run a minimal footprint.

```sh
helm install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost --create-namespace -f values-secondary.yaml
```

