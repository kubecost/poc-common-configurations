# private-registry-helm-values

## Usage

See comments at the top of the [values-private-container-registry.yaml](values-private-container-registry.yaml) File.

See additional documentation <https://www.ibm.com/docs/en/kubecost/self-hosted/3.x?topic=SSW0JQG_3.0.x/install-and-configure/install/provider-installations/air-gapped.htm>

## List current images

To get a dynamic list of current images, run the following command:
> Install yq with brew / pip / etc

```sh
helm template kubecost --repo https://kubecost.github.io/kubecost/ kubecost \
  --skip-tests \
  | yq '..|.image? | select(.)' | sort -u
```

If you don't have yq this should output the same:

```sh
helm template kubecost --repo https://kubecost.github.io/kubecost/ kubecost  \
  --skip-tests \
  | grep 'image:'|sed 's/image: //g'|sed 's/"//g'|sed 's/- //g'|sed 's/ //g' | sort -u
```
