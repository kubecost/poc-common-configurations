Overview:
The scripts in the 'kubecost-api' folder are written in python for interacting with the kubecost REST API. The scripts in this folder are good examples for those who need to pull data using the API as part of a job, cronjob, cloud function, manually, etc.

Scripts:
assets-api-aws-s3.py - This is a simple python script written to interact with the kubecost 'model/assets' API endpoint to retrieve Kubernetes cluster costs broken down by the individual      backing assets in your cluster, as well out-of-cluster assets by service (if configured)

etl-api.py - This is a simple python script written to interact with the kubecost 'model/etl' API endpoint.   This script gives the option to check etl status or audit the etl pipeline.

json-to-jsonl-example.py - This is a simple python script written to interact with the kubecost 'model/allocation' API endpoint.  The script was written to create jsonl output to be consumed by products like BigQuery which require jsonl