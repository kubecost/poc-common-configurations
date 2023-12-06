import boto3

print()
start_date = str(input("What is the start date? e.g. 2023-10-05   "))
end_date = str(input("What is the end date? e.g. 2023-10-06   "))
account_id = str(input("What is your AWS account id?   "))


client = boto3.client('ce')

response = client.get_cost_and_usage(
    TimePeriod={
        'Start': start_date,
        'End': end_date
    },
    Granularity='DAILY',
    Filter = {
        "And": [{
            "Dimensions":{
                "Key": "LINKED_ACCOUNT",
                "Values": [account_id,]
            },
        },{
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