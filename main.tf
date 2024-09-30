provider "aws" {
  region = "us-east-1"  # Define your AWS region
}

# Create IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_ec2_launch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_policy_attachment" "lambda_ec2_launch_policy" {
  name       = "lambda-ec2-launch-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_ec2_policy" {
  name       = "lambda-ec2-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"  # This grants permissions to launch EC2 instances
}
# Create IAM Policy for SQS Permissions
resource "aws_iam_policy" "sqs_policy" {
  name        = "SQSPolicy"
  description = "IAM policy for Lambda to access SQS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      Effect   = "Allow",
      Resource = "*",  # Restrict this to your specific SQS ARN in production
    }]
  })
}

# Attach the SQS Policy to the Lambda Role
resource "aws_iam_role_policy_attachment" "attach_sqs_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.sqs_policy.arn
}

# Define Lambda Function
resource "aws_lambda_function" "launch_ec2" {
  function_name = "LaunchEC2Function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"  # Replace with your actual handler
  runtime       = "python3.8"

  # Package your Lambda code and dependencies into a .zip file
  filename      = "lambda_function.zip"  # This will be the zipped code
}

# Create SQS Queue
resource "aws_sqs_queue" "launch_ec2_queue" {
  name = "LaunchEC2Queue"
}

# Create an Event Source Mapping to trigger the Lambda function from the SQS queue
resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.launch_ec2_queue.arn
  function_name    = aws_lambda_function.launch_ec2.function_name
  enabled          = true
  batch_size       = 1  # Number of messages to process at one time
}

# Output the SQS Queue URL and Lambda Function ARN
output "sqs_queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.launch_ec2_queue.id
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.launch_ec2.arn
}
