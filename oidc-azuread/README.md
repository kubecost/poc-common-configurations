# Kubecost SSO and RBAC - AzureAD Integration

![Enterprise Subscription Required](./images/kubecost-enterprise.png)

## Pre-requisites

- Kubecost is already installed
- Kubecost is accessible via a TLS-enabled Ingress

## AzureAD Configuration

### Register an application

1. Go to Azure Active Directory in the [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Select `Add > App registrations > New registration`
3. Set the appropriate `Name` and `Supported account types`
4. Set the following `Web` Redirect URI https://MY_KUBECOST/model/oidc/authorize

### Configure `values.yaml`

1. Go to Azure Active Directory in the [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Go to `Manage > App registrations`. Then click on your application you just created
3. On the Overview page, make note of the "Application (client) ID" and the "Directory (tenant) ID" for your `values.yaml` later.
4. Click on `Client credentials > New client secret`. Create the secret, then make note of the returned `Value`.

```yaml
# values.yaml
oidc:
  enabled: true
  clientID: "{APPLICATION_CLIENT_ID}"
  clientSecret: "{CLIENT_CREDENTIALS} > {SECRET}"
  secretName: "kubecost-oidc-secret"
  authURL: "https://login.microsoftonline.com/{YOUR_TENANT_ID}/oauth2/v2.0/authorize?client_id={YOUR_CLIENT_ID}&response_type=code&scope=openid&nonce=123456"
  loginRedirectURL: "https://{YOUR_KUBECOST_DOMAIN}/model/oidc/authorize"
  discoveryURL: "https://login.microsoftonline.com/{YOUR_TENANT_ID}/v2.0/.well-known/openid-configuration"
```

### Configure RBAC

