# Disable Pod Security Policies

PSPs are deprecated as of Kubernetes 1.25 and are being removed as of Kubernetes v1.25.

Use the [`disable-psps.yaml`](disable-psps.yaml) with your Helm deployment to disable them.

```shell
helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  -f <your-other-values-files> \
  -f ./disable-psps.yaml
```
