module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  name = "lambda_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  default_security_group_ingress = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      cidr_blocks = "10.0.0.0/16",
      description = "Allow all inbound traffic from within the VPC"
    }
  ]

  default_security_group_egress = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      cidr_blocks = "0.0.0.0/0",
      description = "Allow all outbound traffic"
    }
  ]

  default_security_group_name = "lambda_default_vpc_sg"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow external SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # Allow outbound traffic for all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
