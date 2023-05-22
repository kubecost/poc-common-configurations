# Kubecost Ingress Example Configurations

Pre-requisites:

- An [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

## Examples

[ingress-alb.yaml](ingress-alb.yaml): AWS ALB Ingress

[ingress-basic-auth.yaml](ingress-basic-auth.yaml): HTTPS with basic auth

[ingress-overview-html-default.yaml](ingress-overview-html-default.yaml): Change the default landing page to overview.html (instead of the select cluster page)

[ingress-simple-with-tls.yaml](ingress-simple-with-tls.yaml): Basic example ingress definition with TLS

[ingress-simple.yaml](ingress-simple.yaml): Basic example ingress definition

[ingress-subdir-non-root.yaml](ingress-subdir-non-root.yaml): use your.com/kubecost instead of kubecost on the root path

## Quickstart if using Nginx Ingress Controller (`ingressClassName: nginx`)

https://kubernetes.github.io/ingress-nginx/

```sh
# 1. Nginx helm chart
$ helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# 2. Edit `ingress-simple.yaml` to your desired domain name

# 3. Apply
$ kubectl apply -f ingress-simple.yaml -n kubecost
$ kubectl get ingress -n kubecost

# 4. Configure DNS records. (CNAME for domain names, A for static IP addresses)
```
