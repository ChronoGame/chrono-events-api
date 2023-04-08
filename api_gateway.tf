resource "random_id" "deployment_uuid" {
  byte_length = 8
}

variable "deployment_uuid" {
  description = "Unique identifier for each deployment, used to force redeployment"
  default     = ""
}

resource "aws_api_gateway_deployment" "chrono_deployment" {
  depends_on = [aws_api_gateway_integration.events_integration, aws_api_gateway_integration.categories_integration]

  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  #stage_name  = "prod"
  variables   = { "deployment_uuid" = var.deployment_uuid != "" ? var.deployment_uuid : random_id.deployment_uuid.hex }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_api_gateway_stage" "chrono_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.chrono_api.id
  deployment_id = aws_api_gateway_deployment.chrono_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }

  xray_tracing_enabled = true

  depends_on = [aws_api_gateway_deployment.chrono_deployment]
}

resource "aws_api_gateway_rest_api" "chrono_api" {
  name        = "chrono_api"
  description = "chrono_api"
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "/aws/apigateway/${aws_api_gateway_rest_api.chrono_api.name}"
}