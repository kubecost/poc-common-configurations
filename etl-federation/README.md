# Overview

These are the steps to enable ETL federation with Kubecost.

This is an efficient method to implement multi-cluster Kubecost while using existing prometheus installations. Contact us for help customizing settings.

## Setup
Create and attach policy to kubecost IAM role (or create service account below):

```
aws iam create-policy \
 --policy-name kubecost-s3-federated-policy \
 --policy-document file://policy-kubecost-aws-s3.json
```

Create object-store for kubecost federation:

```
kubectl create secret generic \
  kubecost-metrics -n kubecost \
  --from-file federated-store.yaml
```

If creating a new service account:

```
eksctl utils associate-iam-oidc-provider \
    --cluster your-cluster-name \
    --region eu-central-1 \
    --approve
eksctl create iamserviceaccount \
    --name kubecost-irsa-s3 \
    --namespace kubecost \
    --cluster your-cluster-name \
    --region eu-central-1 \
    --attach-policy-arn arn:aws:iam::111222333:policy/kubecost-s3-federated-policy \
    --approve
```

If using this account, add to helm values:

```
serviceAccount:
  create: false
  name: kubecost-irsa-s3
```

```
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f primary-federator.yaml
```

All agents change clusterID:
```
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f agent-federated.yaml
```
