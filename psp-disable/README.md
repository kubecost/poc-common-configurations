
# Disabling Pod Security Policies 

Pod Security Policies (PSPs) are deprecated as of Kubernetes 1.21 and are being removed in Kubernetes v1.25. The deprecation may cause issues such as pods not spinning up, although  services, deployments, and replicasets are up and running. This can be a key indication of issues with PSPs, especially when running on an older version of Kubernetes.

## Identifying PSP Issues
If you suspect PSP issues due to pods not launching while other components appear unaffected, you can confirm this by describing your replica sets:
```shell
kubectl describe rs <replica-set-name>
```
This command helps identify if PSPs are blocking pod creation due to insufficient or overly restrictive permissions.

## Troubleshooting PSPs

### Method 1: Simple Environment
For clusters that do not have extensive security configurations:
   
 **Disable PSPs Using Helm**
   
   Deploy or update Kubecost with PSP disabled using the [`disable-psps.yaml`](disable-psps.yaml) configuration:
   ```shell
   helm upgrade --install kubecost kubecost/cost-analyzer \
       --namespace kubecost \
       -f <your-other-values-files> \
       -f ./disable-psps.yaml
   ```
   Replace `<your-other-values-files>` with any additional Helm values files you typically use in your deployments.

### Method 2: Advanced Troubleshooting with Privileged PSP

In production clusters, which typically feature complex security configurations, it's common to employ multiple policy enforcement mechanisms such as Kyverno, OPA (Open Policy Agent), and other security configs. These settings can result in a multitude of interdependent security configurations and potentially lead to a cascade of secomperrors when trying to do it the plain simple way.

This method helps stabilize your deployment by granting broader permissions , allowing you to isolate and address specific policy conflicts or restrictions.

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

