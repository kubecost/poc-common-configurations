# Kubecost SSO and RBAC - Azure Entra ID Integration

![Enterprise Subscription Required](./images/kubecost-enterprise.png)

## Overview

Kubecost supports SAML 2.0 providers for:

1. Single sign-on (SSO)
1. Role-based access control (RBAC): controlling read-only or admin access to Kubecost configuration within the UI (optional)
1. Filtering namespaces and clusters based on group membership (optional)

This guide uses Azure Entra ID (formerly called Azure AD) as an example, but the concepts apply to other providers as well.

## Requirements

Both SSO and RBAC require a Kubecost Enterprise plan.

We recommend using our [Helm chart](https://github.com/kubecost/cost-analyzer-helm-chart) to install Kubecost.

## Assistance and Feedback

We are looking for any feedback you may have on these functions and we are here to help!. Please don't hesitate to contact us via our [Slack community](https://kubecost.slack.com/ssb/redirect). Check out #support for any help you may need and drop your introduction in #general.

## AzureAD Configuration

### Create an Enterprise Application in AzureAD for Kubecost (SSO)

1. Go to Azure Active Directory in the [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview) and select `Manage > Enterprise Application` and select `+ New Application`
1. On the "Browse EntraID Gallery" page select `+ Create your own application` and select `Create`

### Configuring your AzureAD Enterprise Application

1. Find and select your Enterprise Application in AzureAD
1. Select `Properties` and update the logo and select `Save`. Feel free to use the [kubecost-logo.png](./images/kubecost-logo.png)
1. Select `Users and Groups`
1. Assign groups you want to have access to Kubecost and select `Assign`
1. Select `Single Sign-on`
1. Select `SAML`
1. On the `Set up Single Sign-On with SAML` page, find the `Basic SAML Configuration` and select `Edit`

   <details><summary>screenshot</summary>

   ![basic saml config](images/aad-basic-saml-cfg.png)

   </details>

1. Populate the `Entity ID` and `Reply URL` with the url to the application root of Kubecost _without a trailing slash_ (https://kubecost.your.com) and select `Save`

1. (Optional) If you intend to use RBAC, you need to add a group claim.
   1. Find the `Attributes & Claims` section of the SSO page and select `Edit`
         <details><summary>screenshot</summary>

         ![attributes and claims](images/aad-attributes-claims.png)

         </details>
   1. Select `+ Add a group claim`, configure your group association and select `Save`. The `Claim name` will be used as the `assertionName` in the [values-saml.yaml](values-saml.yaml) file.

         <details><summary>screenshot</summary>

         ![group claim configuration](images/aad-group-claim.png)

         </details>
   1. Click back to the `Single Sign-on` configuration of your Enterprise Application

1. On the `Single Sign-on` page of your Enterprise Application, copy the link for `App Federation Metadata Url` in the `SAML Certificates` section and add that to the [values-saml.yaml](values-saml.yaml):idpMetadataURL
   <details><summary>screenshot</summary>

   ![saml metadata](images/aad-saml-metadata.png)

   </details>

1. On the same page, in the `SAML Certificates` section: select `download` next to the `Certificate (Base64)` item  to download the X.509 cert. Name it `myservice.cert`
1. Create a secret using the cert:

    ```bash
    kubectl create secret generic kubecost-azuread --from-file myservice.cert --namespace kubecost
    ```

1. With your existing helm install command, append "-f [values-saml.yaml](values-saml.yaml)" to the end.

    >At this point, we recommend testing to ensure SSO works before configuring RBAC below.
    ><BR>Note that there is a troubleshooting section at the end of this readme.

---

## RBAC: Admin/Read Only

The simplest form of RBAC in Kubecost is to have two groups: admin and read only.
>If your goal is to simply have 2 groups- admin and readonly, you do not need to configure filters.
><BR>If you do not configure filters, this message in the logs is expected: `file corruption: '%!s(MISSING)'`

The [values-saml.yaml](values-saml.yaml) file contains the `admin` and `readonly` groups in the RBAC section:

```yaml
  rbac:
    enabled: true
    groups:
      - name: admin
        enabled: true # if admin is disabled, all SAML users will be able to make configuration changes to the kubecost frontend
        assertionName: "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups" # a SAML Assertion, one of whose elements has a value that matches on of the values in assertionValues
        assertionValues:
          - "{group-object-id-1}"
          - "{group-object-id-2}"
      - name: readonly
        enabled: true # if readonly is disabled, all users authorized on SAML will default to readonly
        assertionName:  "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
        assertionvalues:
          - "{group-object-id-3}"
    customGroups: # not needed for simple admin/readonly RBAC
      - assertionName: "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
```

The `assertionName: "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"` needs to match the claim name given in step 8-2 above.

---

## RBAC: Cluster/Namespace/Label/Annotation Filtering

Filters are used to give visibility to a subset of objects in Kubecost. Examples of the various filters available are in [filters.json](./filters.json) and [filters-examples.json](./filters-examples.json). RBAC filtering is capable of all the same types of filtering features as that of the [Allocation API](https://docs.kubecost.com/apis/apis/allocation).

These filters can be configured using groups or user attributes in your AzureAD directory. It is also possible to assign filters to specific users. The example below is using groups.

> **Note**: that you can combine filtering with admin/readonly rights.

Filtering is configured very similarly to the `admin/readonly` above. The same assertion name and values will be used, as is the case in this example.

Kubecost will use this section in the helm values file:

values-saml.yaml:

```yaml
    customGroups: # not needed for simple admin/readonly RBAC
      - assertionName: "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
```

The array of groups obtained during the auth request will be matched to the subject key in the filters.yaml:

filters.json:

```json
{
   "{group-object-id-a}":{
      "allocationFilters":[
         {
            "namespace":"*",
            "cluster":"*"
         }
      ]
   },
   "{group-object-id-b}":{
      "allocationFilters":[
         {
            "namespace":"",
            "cluster":"*"
         }
      ]
   },
   "{group-object-id-c}":{
      "allocationFilters":[
         {
            "namespace":"dev-*,nginx-ingress",
            "cluster":"*"
         }
      ]
   }
}
```

As an example, we will configure the following:

- Admins will have full access to the Kubecost UI and have visibility to all resources
- Kubecost Users, by default, will not have visibility to any namespace and will be readonly. Note that if a group doesn't have access to any resources, the Kubecost UI may appear to be broken.
- The dev-namespaces group will have read only access to the Kubecost UI and only have visibility to namespaces that are prefixed with `dev-` or are exactly `nginx-ingress`

1. In the AzureAD blade, navigate to `Users and Groups`
1. Create groups for kubecost_users, kubecost_admin and kubecost_dev-namespaces. Add all users to the kubecost_users group and the appropriate users to each of the other groups for testing.

    >Kubecost admins will be part of both the read only kubecost_users and kubecost_admin groups. Kubecost will assign the most rights (least restrictive) when there are conflicts.

1. In the Enterprise Application `Members` section, assign the groups you just created.
1. Modify [filters.json](./filters.json) as depicted above.
   1. Replace `{group-object-id-a}` with the Object Id for `kubecost_admin`
   1. Replace `{group-object-id-b}` with the Object Id for `kubecost_users`
   1. Replace `{group-object-id-c}` with the Object Id for `kubecost_dev-namespaces`
1. Create the configmap:

    ```bash
    kubectl create configmap group-filters --from-file filters.json -n kubecost
    ```

> **Note**: that you can modify the configmap without restarting any pods.

   ```bash
   kubectl delete configmap -n kubecost group-filters && kubectl create configmap -n kubecost group-filters --from-file filters.json
   ```

## Troubleshooting / Logs

You can look at the logs on the cost-model container. This is script is currently a work in progress.

```bash
kubectl logs deployment/kubecost-cost-analyzer -c cost-model --follow |grep -v -E 'resourceGroup|prometheus-server'|grep -i -E 'group|xmlname|saml|login|audience'
```

When the group has been matched, you will see:

```bash
2022-08-27T05:32:03.657455982Z INF AUDIENCE: [readonly group:readonly@kubecost.com]
2022-08-27T05:51:02.681813711Z INF AUDIENCE: [admin group:admin@kubecost.com]
```

```bash
configwatchers.go:69] ERROR UPDATING group-filters CONFIG: []map[string]string: ReadMapCB: expect }, but found l, error found in #10 byte of ...|el": "{ "label": "ap|..., bigger context ...|nFilters": [
         {
            "label": "{ "label": "app", "value": "nginx" }"
         }
     |...
```
---

### This is what normal looks like

```bash
2022-09-01T03:47:28.556977486Z INF   http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name NameFormat: Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:admin@kubecost.com}]}
2022-09-01T03:47:28.55700579Z INF   http://schemas.microsoft.com/identity/claims/tenantid: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:http://schemas.microsoft.com/identity/claims/tenantid NameFormat: Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:<TENANT_ID_GUID>}}]}
2022-09-01T03:47:28.557019809Z INF   http://schemas.microsoft.com/identity/claims/objectidentifier: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:http://schemas.microsoft.com/identity/claims/objectidentifier NameFormat: Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:<OBJECT_ID_GUID>}]}
2022-09-01T03:47:28.557052714Z INF   http://schemas.microsoft.com/ws/2008/06/identity/claims/groups: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:http://schemas.microsoft.com/ws/2008/06/identity/claims/groups NameFormat: Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:<GROUP_ID_GUID>}]}
2022-09-01T03:47:28.557067146Z INF   http://schemas.microsoft.com/identity/claims/identityprovider: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:http://schemas.microsoft.com/identity/claims/identityprovider NameFormat: Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:https://sts.windows.net/<TENANT_ID_GUID>/}]}
2022-09-01T03:47:28.557079034Z INF   http://schemas.microsoft.com/claims/authnmethodsreferences: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:http://schemas.microsoft.com/claims/authnmethodsreferences NameFormat: Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:http://schemas.microsoft.com/ws/2008/06/identity/authenticationmethod/password}]}
2022-09-01T03:47:28.557118706Z INF Adding authorizations '[admin group:admin@kubecost.com]' for user
2022-09-01T03:47:28.594663386Z INF Login called
2022-09-01T03:47:28.629402419Z INF Attempting to authenticate saml...
2022-09-01T03:47:28.629509235Z INF Authenticated saml
...
2022-09-01T03:47:29.11007143Z INF AUDIENCE: [admin group:seanp@teamkubecost.onmicrosoft.com]
```
