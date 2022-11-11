# Pre-create ClusterRoles, ClusterRoleBindings, Roles, RoleBindings, and ServiceAccounts

## Overview

Kubecost requires ClusterRoles in order to retrieve the metadata necessary to calculate costs for all cluster resources.
Some organizations don't allow teams to create clusterroles at deployment time. These examples are meant to create the necessary permissions and service accounts that Kubecost needs to functions within the cluster.

> Note: These examples assume the namespace Kubecost is being deployed to is named `kubecost`. If your namespace differs, you will need to update the manifests and the commands below.

Manifests were generated via Helm template:

``` shell
helm template --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost
```

## Deploy Manifests

``` shell
kubectl create namespace kubecost
kubectl apply -n kubecost -f ./manifests
```

## Deploy Kubecost

``` shell
helm upgrade kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost --install -f <your-other-values-files> -f service-accounts.yaml
```
