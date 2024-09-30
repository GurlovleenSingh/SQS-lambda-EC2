# SQS-lambda-EC2
Trigger SQS with boto3 python message and launch EC2 with lambda function

To set up a system where a message sent to an Amazon SQS queue triggers an AWS Lambda function that launches an EC2 instance, you need to perform the following steps:


Create an SQS Queue.

Create a Lambda function to launch EC2 when triggered by SQS.

Install dependencies (like boto3) and zip the code.

Set permissions for Lambda to interact with EC2 and SQS.

Send a message to SQS, which triggers Lambda to launch EC2
