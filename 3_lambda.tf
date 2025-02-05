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

  # VPC configuration
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.lambda_sg.id]

  # IAM role configuration
  create_role = true
  role_name   = "lambda_execution_role" # required when running Lambdas inside a VPC

  attach_network_policy = true
}

# Security Group for Lambda function
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda function"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
