This is still a work in progress, meant as an example method for attached an IAM role to the service account used by Kubecost.

There are multiple methods for doing this, if the method below does not fit your requirements, please reach out to us. 

Using aws with IAM roles attached to service accounts:

Enable oidc provider and create service accounts
```sh
kubectl create ns kubecost
eksctl utils associate-iam-oidc-provider \
    --cluster jesse-eks5 --region us-east-2 \
    --approve
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-cur-athena-thanos \
    --namespace kubecost \
    --cluster jesse-eks5 --region us-east-2 \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-cur-policy \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-athena-policy \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-s3-thanos-policy \
    --approve
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-thanos \
    --namespace kubecost \
    --cluster jesse-eks5 --region us-east-2 \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-s3-thanos-policy \
    --approve
```

Install kubecost:
```sh
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml
kubectl create secret generic aws-service-key -n kubecost --from-file=service-key.json
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml -f values-amazon-primary.yaml
```
