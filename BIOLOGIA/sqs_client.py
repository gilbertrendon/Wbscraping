import boto3
import os

#Get the service resource
sqs = boto3.resource('sqs', region_name='us-east-1', verify='False')

message = """
    {
        "filename": "BIOLOGIA/9256d81.csv",  
        "recordNumber": 27,  
        "source": "BIOLOGIA", 
        "retries": "3",  
        "partsNumber": 3,  
        "part": 2,  
        "rows": [{"row": {"identityNumber":"91527913"}, "scrapingResult": null}]
    }
"""

queue_name = os.environ["AWS_SQS_QUEUE"] 
messageGroupId = "0"

# Get the queue
queue = sqs.get_queue_by_name(QueueName=queue_name)
# limpiar cola
queue.purge()
# Create a new message
response = queue.send_message(MessageBody=message, MessageGroupId=messageGroupId)
# Get the message ID and MD5
print(response.get('MessageId'))
print(response.get('MD5OfMessageBody'))

