resource "aws_api_gateway_resource" "alerts_resource" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  parent_id   = aws_api_gateway_rest_api.chrono_api.root_resource_id
  path_part   = "alerts"
}

resource "aws_api_gateway_method" "alerts_method" {
  rest_api_id   = aws_api_gateway_rest_api.chrono_api.id
  resource_id   = aws_api_gateway_resource.alerts_resource.id
  http_method   = "GET"
  authorization = "NONE"

}

resource "aws_api_gateway_integration" "alerts_integration" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.alerts_resource.id
  http_method = aws_api_gateway_method.alerts_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn

}

resource "aws_api_gateway_method" "alerts_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.chrono_api.id
  resource_id   = aws_api_gateway_resource.alerts_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "alerts_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.alerts_resource.id
  http_method = aws_api_gateway_method.alerts_options_method.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "alerts_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.alerts_resource.id
  http_method = aws_api_gateway_method.alerts_options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "alerts_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.alerts_resource.id
  http_method = aws_api_gateway_method.alerts_options_method.http_method
  status_code = aws_api_gateway_method_response.alerts_options_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}