# Overview

These are the steps to enable ETL federation with Kubecost with the Primary cluster running Kubecost Aggregator.

Federated-ETL is an efficient method to implement multi-cluster Kubecost while using existing Prometheus installations for short-term metrics.

Kubecost Aggregator is the primary query backend for the Kubecost Primary cluster.

> Note: Kubecost can rebuild its data (ETLs) using the Prometheus metrics from each cluster. It is recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.

The example in this directory uses the Kubecost Prometheus server. See the [existing-prometheus](./existing-prometheus/) directory otherwise.

[Contact us](https://www.kubecost.com/contact) for help customizing settings.

## Setup

### Object-Store and Permissions Setup

Create an S3 compatible bucket to use for the Kubecost metrics and attach policy to kubecost service account.

Update [policy-kubecost-aws-s3.json](policy-kubecost-aws-s3.json) and [federated-store.yaml](federated-store.yaml) with your bucket name.

Then create the IAM Policy (note the ARN for the attach-policy-arn below):

```sh
aws iam create-policy \
 --policy-name kubecost-s3-federated-policy \
 --policy-document file://policy-kubecost-aws-s3.json
```

Create the secret for the object-store for kubecost federation:

```sh
kubectl create namespace kubecost
kubectl create secret generic \
  kubecost-object-store -n kubecost \
  --from-file federated-store.yaml
```

Creating a new service account:

```sh
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

### Install Kubecost Primary Instance

Be sure to either set the `CLUSTER_NAME` here or in all 3 locations of the [primary-aggregator.yaml](./primary-aggregator.yaml).

> Note: in the below install command, because the CLUSTER_NAME arguments come after the filename, the arguments will win.

```sh
CLUSTER_NAME=cluster1
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  -f primary-aggregator.yaml \
  --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=$CLUSTER_NAME
```

### Install Agents on all other clusters

Repeat the `Object-Store and Permissions Setup` above for all clusters, using the same S3 bucket.

Be sure to either set the `CLUSTER_NAME` here or in both locations of the [secondary-federated.yaml](secondary-federated.yaml).

> Note: in the below install command, because the CLUSTER_NAME arguments come after the filename, the arguments will win.

```sh
CLUSTER_NAME=cluster2
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f secondary-federated.yaml \
  --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=$CLUSTER_NAME
```
