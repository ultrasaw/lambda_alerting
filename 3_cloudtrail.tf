resource "aws_cloudtrail" "trail" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]

  name           = "cloudtrail_mgmnt_all"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix  = "prefix"
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "cloudtrail-logs-eventbridge-lambda"
  force_destroy = true
}

# resource "aws_s3_bucket_notification" "bucket_notification_cloudtrail" {
#   bucket      = aws_s3_bucket.cloudtrail_logs.id
#   eventbridge = true
# }

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
