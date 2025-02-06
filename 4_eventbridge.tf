module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.3"

  create_bus = false # use the 'default' bus; a custom one requires additional routing setup.

  rules = {
    iam_user_or_key = {
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
    sg_ingress_change = {
      description = "Triggers on Security Group ingress rule changes"
      event_pattern = jsonencode({
        "source": ["aws.ec2"],
        "detail-type": ["AWS API Call via CloudTrail"],
        "detail": {
          "eventSource": ["ec2.amazonaws.com"],
          "eventName": ["AuthorizeSecurityGroupIngress"]
        }
      })
    }
  }

  targets = {
    iam_user_or_key = [
      {
        name = "iam_user_or_key"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnUserOrAccessKeyCreation"
      }
    ]
    sg_ingress_change = [
      {
        name = "sg_ingress_change"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnSGIngressChange"
      }
    ]
  }
}
