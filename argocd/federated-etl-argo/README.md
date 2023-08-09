# Argo CD sample files for Kubecost Enterprise w/ Federated ETL

# Overview

These are the steps to enable ETL federation with Kubecost using Argo CD

Federated-ETL is an efficient method to implement multi-cluster Kubecost while using existing Prometheus installations for short-term metrics.

> Note: Kubecost can rebuild its data (ETLs) using the Prometheus metrics from each cluster. It is recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.

We recommend pulling down a local version of the federated-etl-argo folder for your setup

## Setup

### 1. Object-Store and Permissions Setup

Create an S3 compatible bucket to use for the Kubecost metrics and attach policy to kubecost service account.

Update [iam-kubecost-metrics-s3-policy](iam-kubecost-metrics-s3-policy) and [federated-store.yaml](federated-store.yaml) with your bucket name.

Then create the IAM Policy (note the ARN for the attach-policy-arn below):

```
aws iam create-policy \
 --policy-name kubecost-s3-federated-policy \
 --policy-document file://iam-kubecost-metrics-s3-policy.json
```

Create the secret for the object-store for kubecost federation:

```
kubectl create namespace kubecost
kubectl create secret generic \
  kubecost-object-store -n kubecost \
  --from-file federated-store.yaml
```

Creating a new service account:

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

Once this is complete, you can populate `kubecostModel.federatedStorageConfigSecret` with the object store secret name and `serviceAccount.name` with the irsa service account name in both file://kubecost-primary-federator-values.yaml and file://kubecost-secondary-federated-cluster-values.yaml

*Note: please DO NOT change the name of the file file://federated-store.yaml. Kubecost requires the name of the file behind the secret to remain the same.


### 2. Install Kubecost on the Primary Cluster

*Note: Before installing Kubecost, be sure to edit file://argocd-kubecost-primary.yaml and set the `CLUSTER_NAME` in all 3 locations.

```
argocd app create -f {argocd-kubecost-primary.yaml}
```

### 3. Install Kubecost on All Other Clusters

*Note: Before installing Kubecost, be sure to edit file://argocd-kubecost-secondary.yaml and set the `CLUSTER_NAME` in 2 locations.

```
argocd app create -f {argocd-kubecost-secondary.yaml}
```

### 4. (Optional) Configure Cloud Integration

Once the federated setup is complete, we recommend configuring the cloud integration for most accurate cost information in Kubecost.  Please follow the instructions in the doc link below to configure the cost report setup for your specific cloud provider.

AWS - https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations
GCP - https://docs.kubecost.com/install-and-configure/install/cloud-integration/gcp-out-of-cluster
Azure - https://docs.kubecost.com/install-and-configure/install/cloud-integration/azure-out-of-cluster

Once the cost report is configured for your cloud provider, for AWS we recommend NOT adding values directly to your values file as stated in the step at the link below.

https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations#option-2-add-config-values-via-helm

Instead please use the Multi-Cloud configuration option by follow the steps in the link below for your specific cloud provider.

https://docs.kubecost.com/install-and-configure/install/cloud-integration/multi-cloud

Once you have created the required secret, uncomment `kubecostProductConfigs.cloudIntegrationSecret` and populate the secret in file://kubecost-primary-federator-values.yaml and apply the changes.



## Argo CD for testing

If you don't already have Argo CD Installed, follow these basic instructions.

 > Please consult Argo CD docs for security considerations.

### Install argo on a cluster

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

wait for argo to be ready, then:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
argocd login LB_IP --insecure
argocd cluster add CLUSTER_NAME
```
