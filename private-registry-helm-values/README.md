# private-registry-helm-values

## Usage

See comments at the top of the [values-private-container-registry.yaml](values-private-container-registry.yaml) File.

See additional documentation <https://docs.kubecost.com/install-and-configure/install/provider-installations/air-gapped>

# List current images


To get a dynamic list of current images, run the following command:
> Install yq with brew / pip / etc

```sh
helm template kubecost --repo https://kubecost.github.io/cost-analyzer/ kubecost \
  --set networkCosts.enabled=true \
  --set clusterController.enabled=true \
  | yq '..|.image? | select(.)' | sort -u
```

If you don't have yq this should output the same:

```sh
helm template kubecost --repo https://kubecost.github.io/cost-analyzer/ kubecost  \
  --set networkCosts.enabled=true \
  --set clusterController.enabled=true \
  | grep 'image:'|sed 's/image: //g'|sed 's/"//g'|sed 's/- //g'|sed 's/ //g'|sort -u
```