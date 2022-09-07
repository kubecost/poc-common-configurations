# Kubecost Requests and Limits

Many organizations require a request and/or limit be set for each container when deploying to Kubernetes. This directory contains two examples to assist.

1. [requests-and-limits.yaml](./requests-and-limits.yaml) - for small clusters used for testing Kubecost
1. [large-primary-cluster.yaml](./large-primary-cluster.yaml) - Primary clusters run the full Kubecost UI and reconcile cloud billing. They can consume 10-30gb+ of memory depending on many variables.

## Usage

Pass your requests-and-limits.yaml to the end of your helm install:

```
helm upgrade --install kubecost \
  --repo https://raw.githubusercontent.com/kubecost/openshift-helm-chart/main cost-analyzer \
  --namespace kubecost --create-namespace \
  -f requests-and-limits.yaml
```

 > The rightmost argument in helm wins when there are conflicting values.

See the Kubecost [Tuning Guide](https://guide.kubecost.com/hc/en-us/articles/6446286863383-Tuning-Resource-Consumption) for more details.

See this interesting article regarding CPU limits. Summary: CPU limits are rarely a good idea. [stop-using-cpu-limits](https://home.robusta.dev/blog/stop-using-cpu-limits/)