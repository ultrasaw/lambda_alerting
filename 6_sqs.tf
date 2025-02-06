resource "aws_sqs_queue" "failure" {
  name = "lambda-failure-queue"
}
