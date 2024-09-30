import json
import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    for record in event['Records']:
        message_body = json.loads(record['body'])
        # Extract necessary information from the message
        instance_type = message_body.get('instance_type', 't2.micro')
        # Launch EC2 instance
        response = ec2.run_instances(
            ImageId='ami-0182f373e66f89c85',  # Update with a valid AMI ID
            InstanceType=instance_type,
            MinCount=1,
            MaxCount=1,
            # KeyName='your-key-pair-name',  # Update with your key pair name
        )
        print("Launched EC2 Instance: ", response)
