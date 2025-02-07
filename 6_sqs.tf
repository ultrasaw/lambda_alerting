resource "aws_sqs_queue" "failure" {
  name = "lambda_failure_queue"
}
