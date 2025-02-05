module "eventbridge_rules" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.3"

  bus_name = "lambda_bus_event"

  rules = {
    iam_user_creation = {
      description = "Triggers on IAM user creation"
      event_pattern = jsonencode({
        "source" : ["aws.iam"],
        "detail-type" : ["AWS API Call via CloudTrail"],
        "detail" : {
          "eventSource" : ["iam.amazonaws.com"],
          "eventName" : ["CreateUser"]
        }
      })
    }

    iam_access_key_creation = {
      description = "Triggers when a new access key is created"
      event_pattern = jsonencode({
        "source" : ["aws.iam"],
        "detail-type" : ["AWS API Call via CloudTrail"],
        "detail" : {
          "eventSource" : ["iam.amazonaws.com"],
          "eventName" : ["CreateAccessKey"]
        }
      })
    }
  }

  targets = {
    iam_user_creation = [
      {
        name = "iam_user_creation_target"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnUserCreation"
      }
    ]

    iam_access_key_creation = [
      {
        name = "iam_access_key_creation_target"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnAccessKeyCreation"
      }
    ]
  }
}
