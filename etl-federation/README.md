
Create and attach policy to kubecost IAM role (or create service account below):

```
aws iam create-policy --policy-name kubecost-s3-federated-policy \
 --policy-document file://aws-kubecost-federated-policy.json.json
```

Create object-store for kubecost federation:

```
 kubectl create secret generic kubecost-metrics -n kubecost \
  --from-file etl-federation/federated-store.yaml
```

If creating a new service account:

```
eksctl create iamserviceaccount \         
--name kubecost-irsa-s3 \
--namespace kubecost \
--cluster your-cluster \
--region eu-central-1 \
--attach-policy-arn arn:aws:iam::111122223333:policy/kubecost-s3-federated-policy
```

If using this account, add to helm values:

```
serviceAccount:
  create: false
  name: kubecost-irsa-s3
```
