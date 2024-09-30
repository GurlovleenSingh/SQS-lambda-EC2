import boto3
import json

# Create an SQS client
sqs = boto3.client('sqs')

# Replace with your actual queue URL
queue_url = 'https://sqs.us-east-1.amazonaws.com/992382695152/LaunchEC2Queue'

# Message to be sent
message = {
    'instance_type': 't2.micro',  # Customize this as needed
    # Add other parameters as required
}

# Send the message to the SQS queue
response = sqs.send_message(
    QueueUrl=queue_url,
    MessageBody=json.dumps(message)  # Convert message dict to a JSON string
)

print("Message sent to SQS:", response['MessageId'])
