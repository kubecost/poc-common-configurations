# Deprecated Pod Security Policies

Pod Security Policies (PSPs) are deprecated as of Kubernetes 1.21 and are removed in Kubernetes v1.25. Kubecost no longer supports PSPs. If you want to install Kubecost 2.x.x on an older Kubernetes version where PSPs are deprecated but not yet removed, you may use this method for installation. Please ensure your PSP configurations are compliant and update your security settings accordingly before PSPs are fully phased out.

## Identifying PSP Issues
If you suspect PSP issues due to pods not launching while other components appear unaffected, you can confirm this by describing your replicasets:
```shell
kubectl describe rs <replica-set-name>
```
This command helps identify if PSPs are blocking pod creation due to insufficient or overly restrictive permissions.

### Installing Kubecost 2.x.x on clusters with deprecated PSPs

This method helps stabilize your deployment by granting broader permissions, allowing you to isolate and address specific policy conflicts or restrictions.

You can find the [`privileged-psp.yaml`](privileged-psp.yaml) in this section.

### Steps to Implement a Privileged PSP

1. **Apply the Privileged PSP**
   
   First, apply the pre-existing `privileged-psp.yaml` file:
   ```sh
   kubectl apply -f privileged-psp.yaml
   ```

2. **Create a ClusterRole for the Privileged PSP**

   Create a ClusterRole named `privileged-psp` to manage the use of the privileged PSP:
   ```sh
   kubectl create clusterrole privileged-psp --verb=use --resource=podsecuritypolicies --resource-name=privileged
   ```

3. **Per-Namespace Disablement for Kubecost**

   Ensure that the `kubecost` namespace (or whatever you namespace is) exists (create it if necessary before proceeding). Then, establish a RoleBinding in the `kubecost` namespace to allow all service accounts in this namespace to use the privileged PSP:
   ```sh
   kubectl create rolebinding -n kubecost disable-psp --clusterrole=privileged-psp --group=system:serviceaccounts:kubecost
   ```

### Verify the Setup

Check if the pods are up and running after the changes:
```sh
kubectl get pods -n kubecost
```

This setup ensures that the pods in the `kubecost` namespace can operate without being hindered by restrictive Pod Security Policies.

### Reverting the Configuration

If necessary, you can revert this configuration by removing the RoleBinding in the `kubecost` namespace:
```sh
kubectl delete rolebinding -n kubecost disable-psp
```

