
Goal 
Kubecost 2.0
    3 environments - test, dev, production

Terraform to deploy all components
    Primary cluster
    Secondary cluster

Procedure

Clusters are in multiple AWS accounts. There is one primary cluster in one account - primary account, secondary clusters in same and other AWS accounts.

Apply Enterprise License: ( Store it in SSM, can be manual)
    https://docs.kubecost.com/install-and-configure/advanced-configuration/add-key

Set up S3 bucket in primary accounts
    This is to metrics data to central bucket in primary account
    Secondary accounts should be able to push/pull to S3 bucket

AWS Cloud Integration (Using IRSA) 
    https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integration-using-irsa

Cloud Cost Integration Configured
    For now, we can assume Cur bucket is already configured
    Set up S3 bucket for Athena in primary and Secondary
        - This is store storage for athena query results - it is CUR data
        - Set up AWS athena in every account
        - Crawler in every account
    IAM - we need to use role in every account
        - Create below role in every account
            https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/cur/iam-payer-account-cur-athena-glue-s3-access.json
        - Primary account role should be able to assume secondary account roles
            TODO - Find the role in primary
            https://github.com/kubecost/poc-common-configurations/tree/main/aws/iam-policies/cur
            https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/cur/iam-payer-account-cur-athena-glue-s3-access.json
            The Role should be able to assume roles in other accounts to read from athena query buckets
                https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/cur/iam-payer-account-trust-primary-account.json

Federation Configured:
    It needs to access `S3 bucket in primary accounts` and done with Trust policy. It is below
    Set up a role in primary account
        https://github.com/kubecost/poc-common-configurations/tree/main/aws/etl-federation
    Create Trust policy
        https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/cur/iam-payer-account-trust-primary-account.json
        We need to add all secondary accounts as Principal in the policy so that they can assume the role to access S3 bucket
    Create this role in every account
        https://github.com/kubecost/poc-common-configurations/tree/main/etl-federation-aggregator#setup

Pre requisites
Namespace for Kubecost is already created
