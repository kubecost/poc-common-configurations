# This is a simple python script written to interact with the kubecost 'model/assets' API endpoint.  The script will create a local json output file.
# With the AWS cli configured in your workspace, you have the option to upload the output json file to an AWS S3 bucket.
# Please find more information about the 'model/assets/' endpoint at https://docs.kubecost.com/apis/apis-overview/assets-api

import requests
import json
import logging
import os, uuid
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from datetime import datetime

# Questions

print()
baseUrl = input("What is the base URL for kubecost? e.g. https://kubecost.company.com:  ")
print()

window_param = input("What is the time window? e.g. 1d, 7d, 48h, lastweek, yesterday, today, lastmonth:  " )
print()

aggregate_param = input("What would you like to aggregate by? e.g. account, category, cluster, project, provider, providerid, service, type, unaggregated:  ")
print()

accumulate_param = input("Accumulate? true or false:  ")
print()

# kubecost base URL
api_url = baseUrl+"/model/assets"

# params
params = {"window": window_param, "aggregate": aggregate_param, "accumulate": accumulate_param}

# API response
response = requests.get(api_url, params=params)
response_status = response.status_code
response.json()

# get datetime
current_datetime = datetime.now()
str_current_datetime = str(current_datetime)

# create json output
file_name = "assets-"+str_current_datetime+".json"

with open(file_name, "w") as outfile:
    json.dump(response.json(), outfile)

# Replace <storageaccountname> with the storage account name
account_url = "https://chrism.blob.core.windows.net"
default_credential = DefaultAzureCredential()

# Create the BlobServiceClient object
blob_service_client = BlobServiceClient(account_url, credential=default_credential)

# Fill in the container name here
container_name = "chrism-assets"

azure_blob = ""    

while azure_blob not in ["Yes", "YES", "yes", "Y", "y", "No", "NO" "no", "N", "n"]:

    azure_blob = input("Would you like to upload the json file to an Azure Blob Storage? yes or no:  ")

    if azure_blob in ["Yes", "YES", "yes", "Y", "y"]: 
        
        # Create a blob client using the local file name as the name for the blob
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=file_name)

        print("\nUploading to Azure Storage as blob:\n\t" + file_name)

        # Upload the created file
        with open(file=file_name, mode="rb") as data:
         blob_client.upload_blob(data)

    elif azure_blob in ["No", "NO", "no", "N", "n"]:
        exit()
    else: 
        print()
        print("Please enter yes or no")


print()
print("Current date & time : ", current_datetime)
print()
if response:
  print("Kubecost API response status: "+str(response_status))
else:
  print('Request returned an error.')