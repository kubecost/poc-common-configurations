# Install Kubecost in GKE

## Create Bucket

See: <https://guide.kubecost.com/hc/en-us/articles/4407601822359-GCP-Long-Term-Storage>

```bash
GCP_project_id="guestbook-227502"
GCP_thanos_bucket="jesse-gcp-bucket1"
gsutil mb gs://$GCP_thanos_bucket -l us-east-2

cat <<EOF > bucket-user-role.yaml
title: "Cluster Turndown"
description: "Permissions needed to
- orgpolicy.policy.get
- resourcemanager.projects.get
- storage.multipartUploads.abort
- storage.multipartUploads.create
- storage.multipartUploads.listParts
- storage.objects.create
- storage.objects.get
- storage.objects.list
EOF

# Create a new Role using the permissions listened in the yaml and remove permissions yaml
gcloud iam roles create cluster.turndown.v2 --project $GCP_project_id --file bucket-user-role.yaml
rm -f bucket-user-role.yaml

# Create a new service account with the provided inputs and assign the new role
gcloud iam service-accounts create --project $GCP_project_id $SERVICE_ACCOUNT_NAME --display-name $SERVICE_ACCOUNT_NAME --format json && \
    gcloud projects add-iam-policy-binding $GCP_project_id --member serviceAccount:$SERVICE_ACCOUNT_NAME@$GCP_project_id.iam.gserviceaccount.com --role projects/$GCP_project_id/roles/cluster.turndown.v2 && \
    gcloud iam service-accounts keys create $DIR/service-key.json --iam-account $SERVICE_ACCOUNT_NAME@$GCP_project_id.iam.gserviceaccount.com

```

## Primary Cluster Setup

```bash
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

# GCP service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Below idea MAY work for scripting. tested on eks, aks, gke
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm upgrade kubecost "kubecost/cost-analyzer" --install --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-google-primary.yaml --set networkCosts.enabled=true --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID
```

## All Secondary Clusters Setup

```bash
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Below idea MAY work for scripting. tested on eks, aks, gke
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm upgrade kubecost "kubecost/cost-analyzer" --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-google-secondary.yaml --set networkCosts.enabled=true --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID
```
