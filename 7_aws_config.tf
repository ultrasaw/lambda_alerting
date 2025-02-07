module "aws_config" {
  source  = "cloudposse/config/aws"
  version = "1.5.3"

  create_iam_role                  = true
  force_destroy                    = true
  s3_bucket_id                     = aws_s3_bucket.aws_config_delivery.id
  s3_bucket_arn                    = aws_s3_bucket.aws_config_delivery.arn
  global_resource_collector_region = var.region

  managed_rules = {
    vpc-sg-open-only-to-authorized-ports = {
      description  = "Check if SGs w/ inbound '0.0.0.0/0' or '::/0' only allow connections on authorized ports. NON_COMPLIANT if such SGs don't have ports specified in the rule parameters.",
      identifier   = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS",
      trigger_type = "PERIODIC"
      input_parameters = "" # no ports allow inbound '0.0.0.0/0' or '::/0'
      enabled      = true

      # tags have to be explicitly set in managed rules
      tags = {
        Name        = "lambda_alerting_project"
        Purpose     = "infrastructure for setting up alerting with Lambda / SNS"
        Environment = "dev"
      }
    }
  }
}

resource "aws_s3_bucket" "aws_config_delivery" {
  bucket        = "aws-config-delivery-storage"
  force_destroy = true
}
