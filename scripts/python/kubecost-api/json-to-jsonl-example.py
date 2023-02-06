# This is a simple python script written to interact with the kubecost 'model/allocation' API endpoint.  The script will create a file json and jsonl file.
# This script was intended to create jsonl output to be consumed by products like BigQuery which require jsonl
# Please find more information about the 'model/allocation/' endpoint at https://docs.kubecost.com/apis/apis-overview/allocation

import requests
import json
import jsonlines
from datetime import datetime

requestURL = "https://demo.kubecost.xyz/model/allocation?window=1d"

# get datetime
current_datetime = datetime.now()
str_current_datetime = str(current_datetime)

response = requests.get(requestURL).json()
results = [v for object in response['data'] for v in object.values()]

pretty = json.dumps(results, indent=4)

with open("response"+str_current_datetime+".json", "w") as outfile:
    outfile.write(pretty)

with jsonlines.open("response"+str_current_datetime+".jl", 'w') as writer:
    writer.write_all(results)