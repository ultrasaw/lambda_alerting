module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  function_name = "test_lambda_function"
  description   = "Test Lambda function with VPC access"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"

  # Path to your Lambda function code
  #   source_path = "${path.module}/path-to-your-lambda-code"
  source_path = "./lambda.py"

  publish = true # publish creation/change as new Lambda Function Version; otherwise error when trying to add policies to the same function.

  allowed_triggers = {
    iam_api_rule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["iam_user_or_key_api"]
    }
  }
}
