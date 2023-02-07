# Overview

These are the steps to enable ETL federation with Kubecost.

This is an efficient method to implement multi-cluster Kubecost while using existing prometheus installations. The example in this directory uses the Kubecost Prometheus server. See the [existing-prometheus](./existing-prometheus/) directory for additional configuration required.

Contact us for help customizing settings.

## Setup

### Object-Store and Permissions Setup

Create and attach policy to kubecost IAM role (or create service account below):

```
aws iam create-policy \
 --policy-name kubecost-s3-federated-policy \
 --policy-document file://policy-kubecost-aws-s3.json
```

Create object-store for kubecost federation:

```
kubectl create namespace kubecost
kubectl create secret generic \
  kubecost-object-store -n kubecost \
  --from-file federated-store.yaml
```

If creating a new service account:

```
eksctl utils associate-iam-oidc-provider \
    --cluster your-cluster-name \
    --region us-east-2 \
    --approve
eksctl create iamserviceaccount \
    --name kubecost-irsa-s3 \
    --namespace kubecost \
    --cluster your-cluster-name \
    --region us-east-2 \
    --attach-policy-arn arn:aws:iam::111222333:policy/kubecost-s3-federated-policy \
    --approve
```

### Install Kubecost Primary Instance:

Be sure to either set the `CLUSTER_NAME` here or in both locations of the [primary-federator.yaml](./primary-federator.yaml).

> Note: because the CLUSTER_NAME arguments come after the filename, the arguments will win.

```
CLUSTER_NAME=cluster1
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  -f primary-federator.yaml \
  --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=$CLUSTER_NAME
```


### Install Agents on all other clusters

Repeat the `Object-Store and Permissions Setup` above for all clusters, using the same S3 bucket.

Be sure to either set the `CLUSTER_NAME` here or in both locations of the [agent-federated.yaml](agent-federated.yaml).

> Note: because the CLUSTER_NAME arguments come after the filename, the arguments will win.

```
CLUSTER_NAME=cluster2
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f agent-federated.yaml \
  --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=$CLUSTER_NAME
```
