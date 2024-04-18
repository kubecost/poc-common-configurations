
## Considerations for GCP Private Storage


https://guide.kubecost.com/hc/en-us/articles/4407601822359-GCP-Long-Term-Storage


## Create a Service Account for Federated ETL Metrics Bucket

Follow this: https://cloud.google.com/iam/docs/creating-managing-service-accounts#iam-service-accounts-create-gcloud

Example of the commands needed are below. Note that the gcloud/api may change- in which case, please reference the above guide to create a blob storage account.

export PROJECT_ID=$(gcloud config get-value project)
export IAM_ACCOUNT="kubecost-iam-user"
export IAM_BUCKET_ROLE="kubecost-iam-role"
gcloud iam service-accounts create $IAM_ACCOUNT
gcloud iam service-accounts keys create $IAM_ACCOUNT.json --iam-account=$IAM_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$IAM_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com --role=projects/$PROJECT_ID/roles/$IAM_BUCKET_ROLE

gcloud iam service-accounts keys create --iam-account=$IAM_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com ~/.gcp/$IAM_ACCOUNT.json
cat ~/.gcp/$IAM_ACCOUNT.json

