# Argo CD sample files for Kubecost Enterprise

## Installation

### Prerequisists

Follow ReadMe-Enterprise to setup cloud-intregration and object-storage secrets for your given cloud provider:
[AWS](../aws/README-enterprise.md)
[Azure](../azure/README-enterprise.md)
[GCP](../gcp/README-enterprise.md)

### Install Kubecost on the Primary Cluster

```
argocd app create -f https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/argocd/argocd-kubecost-primary.yaml
```

### Install Kubecost on All Other Clusters

```
argocd app create -f https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/argocd/argocd-kubecost-secondary.yaml
```

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
