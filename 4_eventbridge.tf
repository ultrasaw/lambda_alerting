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
    sg_ingress_non_private_ip = {
      description = "Triggers on Security Group ingress rule changes"
      event_pattern = jsonencode({
        "source" : ["aws.config"],
        "detail-type" : ["Config Rules Compliance Change"],
        "detail" : {
          "messageType" : ["ComplianceChangeNotification"],
          "configRuleName" : ["vpc-sg-open-only-to-authorized-ports"],
          "newEvaluationResult" : {
            "complianceType" : ["NON_COMPLIANT"]
          }
        }
      })
    }
    s3_bucket_policy_change = {
      description = "Triggers on S3 bucket policy changes"
      event_pattern = jsonencode({
        "source": ["aws.s3"],
        "detail-type": ["AWS API Call via CloudTrail"],
        "detail": {
          "eventSource": ["s3.amazonaws.com"],
          "eventName": ["PutBucketPolicy", "PutBucketCors", "PutBucketPublicAccessBlock", "DeleteBucketPolicy", "DeleteBucketCors", "DeleteBucketPublicAccessBlock"]
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
    sg_ingress_non_private_ip = [
      {
        name = "sg_ingress_non_private_ip"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnSGIngress"
      }
    ]
    s3_bucket_policy_change = [
      {
        name = "s3_bucket_policy_change"
        arn  = module.lambda_function.lambda_function_arn
        id   = "InvokeLambdaOnBucketPolicyChange"
      }
    ]
  }
}
