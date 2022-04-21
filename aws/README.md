# Kubecost Setup for AWS

[Enterprise Setup](README-enterprise.md)

[Business Setup](README-business.md)

---


The configuration files (yaml/json) have placeholders for the variables needed. They are listed below in order to prevent duplicated efforts. The sample-values will look similar to yours.

The variables below are are denoted like this:
- `variable:  sample-value`

Just replace the `sample-value` with yours. The link at the top of each section will bring you to the Kubecost documentation with more detail.

---

## Cluster Name / ID (values*.yaml)

>Note that there are two places that this is used, in the kubecostProductConfigs.clusterName and prometheus.server.global.external_labels.cluster_id
- `kubecostProductConfigs_clusterName: aws-cluster1`

https://guide.kubecost.com/hc/en-us/articles/4407595928087-AWS-Cloud-Integration#spot-data-feed-integration

- `AWS_kubecostProductConfigs_projectID: 29794111111`
- `AWS_kubecostProductConfigs_awsSpotDataRegion: us-east-2`
- `AWS_kubecostProductConfigs_awsSpotDataBucket: kubecost-spot-feed-us-east-2`

---

## service-key.json
https://guide.kubecost.com/hc/en-us/articles/4407595928087-AWS-Cloud-Integration#step-4-attaching-iam-permissions-to-kubecost

- `AWS_service_key_aws_access_key_id:  AKIAUKXXWPGDSAMPLE`
- `AWS_service_key_aws_secret_access_key:  3wHsqewG1wc9jtMrjs6e6cWESAMPLE`

---

## cloud-integration.json

https://guide.kubecost.com/hc/en-us/articles/4407595928087-AWS-Cloud-Integration

- `AWS_cloud_integration_athenaBucketName: sample-cur`
- `AWS_cloud_integration_athenaRegion: us-east-2`
- `AWS_cloud_integration_athenaDatabase: athenacurcfn_sample_cur`
- `AWS_cloud_integration_athenaTable: sample-cur`
- `AWS_cloud_integration_athena_projectID: 29794111111`
- `AWS_cloud_integration_athena_serviceKeyName: AKIAUKXXWPGDSAMPLE`
- `AWS_cloud_integration_athena_serviceKeySecret: iGhEOeZNvRzsyS517LrpI+SAMPLE//`

---

## object-store.yaml

https://guide.kubecost.com/hc/en-us/articles/4407595952151-AWS-Long-Term-Storage

- `AWS_object_store_bucket: sample-thanos-store`
- `AWS_object_store_endpoint: s3.amazonaws.com`
- `AWS_object_store_region: us-east-2`
- `AWS_object_store_access_key: AKIAUKXXWPGDSAMPLE`
- `AWS_object_store_secret_key: iGhEOeZNvRzsyS517LrpI+SAMPLE//`