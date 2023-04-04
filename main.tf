resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_execution_role.arn

  s3_bucket = aws_s3_bucket.csv_bucket.bucket
  s3_key    = "deployment/${var.deployment_number}/hello_world.zip"
}

