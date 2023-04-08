
resource "aws_lambda_permission" "events_apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke-Events"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.chrono_api.execution_arn}/*/${aws_api_gateway_method.events_method.http_method}${aws_api_gateway_resource.events_resource.path}"
}

resource "aws_lambda_permission" "categories_apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke-Categories"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.chrono_api.execution_arn}/*/${aws_api_gateway_method.categories_method.http_method}${aws_api_gateway_resource.categories_resource.path}"
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3_read_policy"
  description = "A policy to read a CSV file from a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.csv_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read_policy_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "lambda_logs_policy"
  description = "A policy to allow Lambda function to create and write logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_policy" "api_gateway_logs_policy" {
  name        = "api_gateway_logs_policy"
  description = "A policy to allow API Gateway to write logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs_policy_attachment" {
  policy_arn = aws_iam_policy.api_gateway_logs_policy.arn
  role       = aws_iam_role.api_gateway_execution_role.name
}

resource "aws_iam_role" "api_gateway_execution_role" {
  name = "api_gateway_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "firehose_policy" {
  name   = "firehose_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.stats_bucket.arn,
          "${aws_s3_bucket.stats_bucket.arn}/*"
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "kinesis:Get*",
          "kinesis:List*",
          "kinesis:Describe*"
        ]
        Effect   = "Allow"
        Resource = aws_kinesis_stream.stat_stream.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
  policy_arn = aws_iam_policy.firehose_policy.arn
  role       = aws_iam_role.firehose_role.name
}
