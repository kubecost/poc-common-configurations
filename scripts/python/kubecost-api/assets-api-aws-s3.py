# This is a simple python script written to interact with the kubecost 'model/assets' API endpoint.  The script will create a local json output file.
# With the AWS cli configured in your workspace, you have the option to upload the output json file to an AWS S3 bucket.
# Please find more information about the 'model/assets/' endpoint at https://docs.kubecost.com/apis/apis-overview/assets-api

import requests
import json
import logging
import os
import sys
import threading
import boto3
from botocore.exceptions import ClientError
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


class ProgressPercentage(object):

    def __init__(self, file_name):
        self._filename = file_name
        self._size = float(os.path.getsize(file_name))
        self._seen_so_far = 0
        self._lock = threading.Lock()

    def __call__(self, bytes_amount):
        # To simplify, assume this is hooked up to a single filename
        with self._lock:
            self._seen_so_far += bytes_amount
            percentage = (self._seen_so_far / self._size) * 100
            sys.stdout.write(
                "\r%s  %s / %s  (%.2f%%)" % (
                    self._filename, self._seen_so_far, self._size,
                    percentage))
            sys.stdout.flush()

aws_s3 = ""

while aws_s3 not in ["Yes", "YES", "yes", "Y", "y", "No", "NO" "no", "N", "n"]:

    aws_s3 = input("Would you like to upload the json file to an S3 bucket? yes or no:  ")

    if aws_s3 in ["Yes", "YES", "yes", "Y", "y"]: 
        
        print()
        bucket_name = input("What S3 bucket do you want to upload the json file to? e.g. my-bucket-name  ")

        # boto s3 bucket
        bucket = bucket_name
        object_name = file_name

        s3 = boto3.resource('s3')

        # All the boto stuff, S3 file upload, https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html
        def upload_file(file_name, bucket, object_name=None):

        # If S3 object_name was not specified, use file_name
            if object_name is None:
                object_name = os.path.basename(file_name)

        # Upload the file
            s3_client = boto3.client('s3')
            try:
                response = s3_client.upload_file(file_name, bucket, object_name, Callback=ProgressPercentage(file_name))
            except ClientError as e:
                logging.error(e)
                return False
            return True

        s3 = boto3.client('s3')
        with open(file_name, "rb") as f:
            s3.upload_fileobj(f, bucket, object_name)

    elif aws_s3 in ["No", "NO", "no", "N", "n"]:
        exit()
    else: 
        print()
        print("Please enter yes or no")



# Print all the things: response status + datetime
print()
print("Current date & time : ", current_datetime)
print()
if response:
  print("Kubecost API response status: "+str(response_status))
else:
  print('Request returned an error.')