# Kubecost with AWS Distro for Open Telemetry

## Overview

This guide will walk you through the steps to deploy Kubecost with AWS Distro for Open Telemetry (ADOT) to collect metrics from your Kubernetes cluster.

## Prerequisites

Follow AWS guide to install the ADOT daemonset: <https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-OpenTelemetry.html>

Update all configuration files in this folder that contain `YOUR_*` with your values.

## Configuration

1. Update all configuration files with your cluster name (replace all `YOUR_CLUSTER_NAME_HERE`). The examples use the key of `cluster` for the cluster name. You can use any key you want, but you will need to update the configmap and deployment files to match. A simplified version of the ADOT DS installation is below.

2. Add the Kubecost scrape config to the ADOT Prometheus configmap:

    Note that this sample configmap also contains cadvisor metrics, which is required by Kubecost.

    ```bash
    kubectl apply -f example-configs/prometheus-daemonset.yaml
    ```

    Alternatively, you can add these items to your [existing configmap](example-configs/kubecost-adot-scrape-config.yaml)

3. Restart the ADOT daemonset to pick up the new configmap:

    ```bash
    kubectl rollout restart daemonset -n aws-otel-collector
    ```

4. Create the Kubecost namespace:

    ```bash
    kubectl create ns kubecost-agent
    ```

5. Create the AWS IAM policy to allow Kubecost to query metrics from AMP:

    ```bash
    aws iam create-policy --policy-name kubecost-read-amp-metrics --policy-document file://iam-read-amp-metrics.json
    ```

6. Create the AWS IAM policy to allow Kubecost to write to the `federated-store` S3 bucket:

    ```bash
    aws iam create-policy --policy-name qa-bucket-policy --policy-document file://iam-kubecost-metrics-s3-policy.json
    ```

7. Configure the Kubecost Service Account:

    ```bash
    eksctl create iamserviceaccount \
    --name kubecost-sa \
    --namespace kubecost-agent \
    --cluster qa-serverless2 --region YOUR_REGION \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-read-amp-metrics \
    --attach-policy-arn arn:aws:iam::297945954695:policy/qa-bucket-policy \
    --override-existing-serviceaccounts --approve --profile admin
    ```

8. Create the Kubecost federated s3 object store secret.

    Copy the output from:

    ```bash
    base64 federated-store.yaml|tr -d '\n'
    ```

    And replace the place holder in `values-kubecost-s3-federated-store.yaml`

9. Deploy the Kubecost agent:

    ```bash
    helm install kubecost-agent \
        kubecost/cost-analyzer \
        -f values-kubecost-agent.yaml \
        -f values-kubecost-s3-federated-store.yaml
    ```

## ADOT Daemonset

