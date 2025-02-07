module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  function_name = "lambda_notify_sns"
  description   = "Lambda function to notify on security-related events via SNS"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"

  # Path to your Lambda function code
  source_path = "./src/lambda.py"

  publish = true # publish creation/change as new Lambda Function Version; otherwise error when trying to add policies to the same function.

  create_async_event_config = true
  attach_async_event_policy = true

  maximum_event_age_in_seconds = 300
  maximum_retry_attempts       = 1

  allowed_triggers = {
    iam_rule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["iam_user_or_key"]
    }
    sg_ingress_rule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["sg_ingress_non_private_ip"]
    }
    s3_policy = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["s3_bucket_policy_change"]
    }
  }

  destination_on_failure = aws_sqs_queue.failure.arn
  destination_on_success = aws_sns_topic.success.arn
}
