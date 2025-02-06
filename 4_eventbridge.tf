module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.3"

  create_bus = false # use the 'default' bus; a custom one requires additional routing setup.

  rules = {
    iam_user_or_key_api = {
      description = "Triggers on IAM user or access key creation via API"
      event_pattern = jsonencode({
        "source" : ["aws.iam"],
        "detail-type" : ["AWS API Call via CloudTrail"],
        "detail" : {
          "eventSource" : ["iam.amazonaws.com"],
          "eventName" : ["CreateUser", "CreateAccessKey"]
        }
      })
    }
  }

  targets = {
    iam_user_or_key_api = [
      {
        name = "iam_user_or_key_api"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnUserOrAccessKeyCreationAPI"
      }
    ]
  }
}
