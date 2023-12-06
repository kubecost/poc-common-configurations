import boto3

print(
'''
-------------------------------------------------------------------------------------------------

This script allows you to get the exact Amortized cost of an EC2 instance from AWS Cost Explorer.

Before you input the information below, find a specific Provider ID in Kubecost for an individual node by following the instructions below.

1. Visit the Kubecost UI and navigating to Monitor-->Assets.
2. Select the Day/Date button and select an single day from the date-range. We suggest a single day at least 3 days prior to today's date, e.g. 10/07/2023-10/07/2023
3. Select the Aggregation button and aggregate by 'Cluster'
4. Find the cluster you wish to use and select it.
5. Select 'Node' from the listings.
6. You will now see individual node line items. Copy one of the Provider IDs from the 'Provider ID' Column.
7. Record/Note the Cost for the chosen node in the 'Cost' column

Now follow the prompts below inputing the start date, end date and EC2 instance Resource ID.

We suggest using a single day to compare costs, e.g. start date = 2023-10-07, end date = 2023-10-08.

-------------------------------------------------------------------------------------------------
'''
)

print()
start_date = str(input("What is the start date? e.g. 2023-10-05   "))
end_date = str(input("What is the end date? e.g. 2023-10-06   "))
provider_id = str(input("What is the EC2 instance_id? e.g i-bcsakjbe234bkbs   "))


client = boto3.client('ce')

response = client.get_cost_and_usage_with_resources(
    TimePeriod={
        'Start': start_date,
        'End': end_date
    },
    Granularity='DAILY',
    Filter = {
        "And": [{
            "Dimensions": {
                "Key": "RESOURCE_ID",
                "Values": [provider_id,]
            },
        },
        {
            "Not": {
                "Dimensions": {
                    "Key": "RECORD_TYPE",
                    "Values": ['Refund',]
                }
            }
        }]
    },
    Metrics=['AMORTIZED_COST'],
    GroupBy=[
        {
            'Type': 'DIMENSION',
            'Key': 'SERVICE'
        }
    ]
)

print(response)