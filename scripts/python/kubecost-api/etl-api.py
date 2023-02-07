# This is a simple python script written to interact with the kubecost 'model/etl' API endpoint.  The script will create a file and print output of either etl status or audit.
# Please find more information about the 'model/etl/' endpoint at https://docs.kubecost.com/apis/apis-overview/audit-api 

import requests
import json
from datetime import datetime

print()
baseUrl = input("What is the base URL for kubecost? e.g. https://kubecost.company.com:  ")
print()

action = input("What do you want to do? e.g. status, audit:  ")
print()

# kubecost base URL
api_url = baseUrl+"/model/etl/"+action

# API response
response = requests.get(api_url)
response_status = response.status_code
response.json()

# get datetime
current_datetime = datetime.now()
str_current_datetime = str(current_datetime)

# create json output
file_name = "etl-"+str_current_datetime+".json"

with open(file_name, "w") as outfile:
    json.dump(response.json(), outfile)


# Print all the things: response status + datetime + file creation
print("Current date & time : ", current_datetime)

print(response_status)

if response:
  print('Request is successful.')
else:
  print('Request returned an error.')

print(response.json())