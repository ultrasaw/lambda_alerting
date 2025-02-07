variable "region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_event_age" {
  type    = number
  default = 300
}

variable "lambda_retries" {
  type    = number
  default = 1
}
