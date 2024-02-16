# Kubecost with AWS Distro for Open Telemetry

## Overview

This guide will walk you through the steps to deploy Kubecost with AWS Distro for Open Telemetry (ADOT) to collect metrics from your Kubernetes cluster.

## Prerequisites

Follow AWS guide to install the ADOT daemonset: <https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-OpenTelemetry.html>

Update all configuration files in this folder that contain `YOUR_*` with your values.

This guide assumes that the Kubecost helm release name and the Kubecost namespace are equal, which allows a global find and replace on `YOUR_NAMESPACE`.

## Architecture Diagram

![Architecture Diagram](multi-cluster-prometheus-kubecost-architecture.png)

## Configuration

1. Update all configuration files with your cluster name (replace all `YOUR_CLUSTER_NAME_HERE`). The examples use the key of `cluster` for the cluster name. You can use any key you want, but you will need to update the configmap and deployment files to match. A simplified version of the ADOT DS installation is below.


### ADOT Configuration

Deploy the ADOT Daemonset, there are many options for this. At a minimum, Kubecost needs the provided scrape config to be added to the ADOT Prometheus configmap.

1. Add the Kubecost scrape config to the ADOT Prometheus configmap:

    Note that this sample configmap also contains cadvisor metrics, which is required by Kubecost.

    ```bash
    kubectl apply -f example-configs/prometheus-daemonset.yaml
    ```

Alternatively, you can add these items to your [existing configmap](example-configs/kubecost-adot-scrape-config.yaml)


### Kubecost Agent Installation

1. Create the Kubecost namespace:

    ```bash
    kubectl create ns YOUR_NAMESPACE
    ```

1. Create the AWS IAM policy to allow Kubecost to query metrics from AMP:

    ```bash
    aws iam create-policy --policy-name kubecost-read-amp-metrics --policy-document file://iam-read-amp-metrics.json
    ```

1. Create the AWS IAM policy to allow Kubecost to write to the `federated-store` S3 bucket:

    ```bash
    aws iam create-policy --policy-name kubecost-bucket-policy --policy-document file://iam-kubecost-metrics-s3-policy.json
    ```

1. Configure the Kubecost Service Account:

    * If the following fails, be sure that IRSA is enabled on your EKS cluster. <https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html>

    ```bash
    eksctl create iamserviceaccount \
    --name kubecost-sa \
    --namespace YOUR_NAMESPACE \
    --cluster qa-serverless2 --region YOUR_REGION \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-read-amp-metrics \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-bucket-policy \
    --override-existing-serviceaccounts --approve --profile admin
    ```

2. Create the Kubecost federated s3 object store secret.

    * There are many ways to create the secret, the below method may work best for automated tools.

    Copy the output from:

    ```bash
    base64 federated-store.yaml|tr -d '\n'
    ```

    And replace the place holder in `values-kubecost-s3-federated-store.yaml`

3. Deploy the Kubecost agent:

    ```bash
    helm install YOUR_NAMESPACE \
        kubecost/cost-analyzer \
        -f values-kubecost-agent.yaml \
        -f values-kubecost-s3-federated-store.yaml
    ```

### Kubecost Primary Installation

This assumes you have created the policies above. If using multiple AWS accounts, you will need to create the policies in each account.

1. Create the Kubecost namespace:

    ```bash
    kubectl create ns YOUR_NAMESPACE
    ```

1. Configure the Kubecost Service Account:

    ```bash
    eksctl create iamserviceaccount \
        --name kubecost-sa \
        --namespace YOUR_NAMESPACE \
        --cluster YOUR_PRIMARY_CLUSTER_NAME --region YOUR_REGION \
        --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-read-amp-metrics \
        --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-bucket-policy \
        --override-existing-serviceaccounts --approve --profile admin
    ```

1. Install Kubecost Primary:

    ```bash
    helm install YOUR_NAMESPACE -n YOUR_NAMESPACE \
        kubecost/cost-analyzer \
        -f values-kubecost-primary.yaml \
        -f values-kubecost-s3-federated-store.yaml
    ```

## ADOT Daemonset Easy Install

[All in one ADOT DS config](example-configs/prometheus-daemonset.yaml)