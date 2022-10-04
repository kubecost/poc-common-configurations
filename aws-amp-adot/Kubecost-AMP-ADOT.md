Kubecost + ADOT


# PRIMARY CLUSTER

# 1-Install Kubecost with default options
helm3 upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version 1.97.0 \
--namespace kubecost --create-namespace \
-f https://tinyurl.com/kubecost-amazon-eks

# 2-Create new AMP instance and take note of your AMP instance ID

export AWS_REGION=<YOUR-AWS-REGION>
aws amp create-workspace --alias kubecost-amp --region $AWS_REGION

# 3-Set env for integrating Kubecost with AMP

export YOUR_CLUSTER_NAME=linh-eks-test
export AWS_REGION=us-west-2
export CLUSTER_ID=kubecost-aws-adot
export AMP_WORKSPACE_ID=ws-ec8b94ab-af50-43f4-92fc-bae0ebca7fe5
export REMOTEWRITEURL="https://aps-workspaces.us-west-2.amazonaws.com/workspaces/${AMP_WORKSPACE_ID}/api/v1/remote_write"
export QUERYURL="http://localhost:8005/workspaces/${AMP_WORKSPACE_ID}"

# 4-Set up IRSA to allow Kubecost and Prometheus to read & write metrics from AMP

cat <<EOF > /tmp/PermissionPolicyQuery.json
{
  "Version": "2012-10-17",
   "Statement": [
       {"Effect": "Allow",
        "Action": [
           "aps:QueryMetrics",
           "aps:GetSeries", 
           "aps:GetLabels",
           "aps:GetMetricMetadata"
        ], 
        "Resource": "*"
      }
   ]
}
EOF

IAM_POLICY=$(aws iam create-policy --policy-name kubecost-adot-policy \
  --policy-document file:///tmp/PermissionPolicyQuery.json \
  --query 'Policy.Arn' --output text)

kubectl create namespace adot-col

eksctl create iamserviceaccount \
    --name amp-iamproxy-ingest-service-account \
    --namespace adot-col \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
    --attach-policy-arn ${IAM_POLICY} \
    --override-existing-serviceaccounts \
    --approve

eksctl create iamserviceaccount \
    --name kubecost-cost-analyzer \
    --namespace kubecost \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
    --override-existing-serviceaccounts \
    --approve

# Install ADOT

k apply -f /Users/linhlam/Documents/Demo/AMP/prometheus-daemonset.yml

# 5-Integrating Kubecost with AMP

## No Kubecost-amp file

helm3 upgrade -i kubecost oci://public.ecr.aws/kubecost/cost-analyzer --version 1.97.0 \
--namespace kubecost --create-namespace \
--set global.amp.enabled=true \
--set global.amp.sigv4.region=us-west-2 \
--set sigV4Proxy.region=us-west-2 \
--set sigV4Proxy.host=aps-workspaces.us-west-2.amazonaws.com \
--set global.amp.prometheusServerEndpoint=${QUERYURL} \
--set global.amp.remoteWriteService=${REMOTEWRITEURL} \
--set global.prometheus.enabled=false \
--set kubecostProductConfigs.clusterName=${CLUSTER_ID} \
--set prometheus.server.global.external_labels.cluster_id=${CLUSTER_ID} \
-f https://tinyurl.com/kubecost-amazon-eks 

## With Kubecost-amp file

helm3 upgrade kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version 1.97.0 \
--namespace kubecost \
-f https://tinyurl.com/kubecost-amazon-eks \
-f https://tinyurl.com/kubecost-amp \
--set global.amp.prometheusServerEndpoint=${QUERYURL} \
--set global.amp.remoteWriteService=${REMOTEWRITEURL} \
--set global.prometheus.enabled="false" \
--set kubecostProductConfigs.clusterName=${CLUSTER_ID} \
--set prometheus.server.global.external_labels.cluster_id=${CLUSTER_ID}

# 6-Verifying your Kubecost set up is using AMP
http://localhost:9090/model/status


# ADDITIONAL CLUSTERS

The installation steps are similar to PRIMARY CLUSTER except you do not need to do step 1 , and you need to update these env var below to match with your ADDITONAL CLUSTERS. Please note that the AMP WORKSPACE ID is the same as Primary cluster

export YOUR_CLUSTER_NAME=linh-eks-test
export CLUSTER_ID=kubecost-aws-adot-2
export AWS_REGION=us-west-2
export AMP_WORKSPACE_ID=ws-ec8b94ab-af50-43f4-92fc-bae0ebca7fe5
export REMOTEWRITEURL="https://aps-workspaces.us-west-2.amazonaws.com/workspaces/${AMP_WORKSPACE_ID}/api/v1/remote_write"
export QUERYURL="http://localhost:8005/workspaces/${AMP_WORKSPACE_ID}"
