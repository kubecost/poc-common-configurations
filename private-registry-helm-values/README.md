# private-registry-helm-values

## Usage

See comments at the top of the [values-private-container-registry.yaml](values-private-container-registry.yaml) File.

See additional documentation <https://docs.kubecost.com/install-and-configure/install/provider-installations/air-gapped>

For a minimal footprint, see [kubecost-minimal-install.yaml](kubecost-minimal-install.yaml)


# List current images


To get a dynamic list of current images, run the following command:
> Install yq with brew / pip / etc

```sh
helm template kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --set networkCosts.enabled=true \
  --set global.thanos.enabled=true \
  --set clusterController.enabled=true \
  | yq '..|.image? | select(.)' | sort -u
```

If you don't have yq this should output the same:

```sh
helm template kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer  \
  --set networkCosts.enabled=true \
  --set global.thanos.enabled=true \
  --set clusterController.enabled=true \
  | grep 'image:'|sed 's/image: //g'|sed 's/"//g'|sed 's/- //g'|sed 's/ //g'|sort -u
```