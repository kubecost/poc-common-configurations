# Kubecost SSO and RBAC - AzureAD Integration

> **Note**: This feature requires an Enterprise license.

## Pre-requisites

- Kubecost is already installed
- Kubecost is accessible via a TLS-enabled Ingress

## Register an application in AzureAD

1. Go to Azure Active Directory in the [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Select `Add > App registrations > New registration`
3. Set the appropriate `Name` and `Supported account types`
4. Set the following `Web` Redirect URI: `https://MY_KUBECOST/model/oidc/authorize`

## Configure `values.yaml`

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

## (optional) Configure RBAC

Configure Roles:

1. Go to Azure Active Directory in the [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Go to `Manage > App registrations`. Then click on your application you just created.
3. Go to `Manage > App roles`.
4. Click `Create app role`. Configure with the following example values:
   1. Display name: admin
   2. Allowed member types: Users/Groups
   3. Value: admin
   4. Description: Admins have read/write permissions via the Kubecost frontend
   5. Do you want to enable this app role: Yes

Attach the Role you just created, to Users and Groups:

1. Go to Azure Active Directory in the [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Go to `Manage > Enterprise applications`. Search for the name of your application, then click on it.
3. Go to `Manage > Users and groups`.
4. Click `Add user/group`. Select the desired group. Select the "admin" role you just created. Or another role you created in "App registrations".

Add these to your existing `values.yaml`:

```yaml
oidc:
  enabled: true
  rbac:
    enabled: true
    groups:
      - name: admin
        # If admin is disabled, all authenticated users will be able to make configuration changes to the kubecost frontend
        enabled: true
        # Set this exact value for AzureAD. This is the string AzureAD uses in its OIDC tokens.
        claimName: "roles"
        # These strings need to exactly match with the App roles created in AzureAD
        claimValues:
          - "admins"
          - "superusers"
      - name: readonly
        # If readonly is disabled, all authenticated users will default to readonly
        enabled: true
        claimName: "roles"
        claimValues:
          - "readonly"
```

## Troubleshooting

### Option 1: Inspect all network requests made by browser

Use [your browser's devtools](https://developer.chrome.com/docs/devtools/network/) to observe network requests made between you, your Identity Provider, and your Kubecost. Pay close attention to cookies, and headers.

### Option 2: Review logs, and decode your JWT tokens

```sh
kubectl logs deploy/kubecost-cost-analyzer
```

- Search for `oidc` in your logs to follow events
- Pay attention to any `WRN` related to OIDC
- Search for `Token Response`, and try decoding both the `access_token` and `id_token` to ensure they are well formed (https://jwt.io/)

### Option 3: Enable debug logs for more granularity on what is failing

[Docs ref](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.103/README.md?plain=1#L63-L75)

```yaml
kubecostModel:
  extraEnv:
    - name: LOG_LEVEL
      value: debug
```

### Kubecost Support

For further assistance, reach out to support@kubecost.com and provide logs, and a [HAR file](https://support.google.com/admanager/answer/10358597?hl=en).

<!-- TODO:
- screenshots
- troubleshooting OIDC (HAR file, decoding the id_token and access_token, debug logs)
-->