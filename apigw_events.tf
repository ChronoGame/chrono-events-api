resource "aws_api_gateway_resource" "events_resource" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  parent_id   = aws_api_gateway_rest_api.chrono_api.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_method" "events_method" {
  rest_api_id   = aws_api_gateway_rest_api.chrono_api.id
  resource_id   = aws_api_gateway_resource.events_resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.cat_filter" = true
    "method.request.querystring.num_events" = true
    "method.request.querystring.random" = true

  }
}

resource "aws_api_gateway_integration" "events_integration" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.events_resource.id
  http_method = aws_api_gateway_method.events_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn

  request_parameters = {
    "integration.request.querystring.cat_filter" = "method.request.querystring.cat_filter"
    "integration.request.querystring.num_events" = "method.request.querystring.num_events"
    "integration.request.querystring.random" = "method.request.querystring.random"
  }

  depends_on = [
    aws_lambda_function.hello_world,
  ]
}

resource "aws_api_gateway_method" "events_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.chrono_api.id
  resource_id   = aws_api_gateway_resource.events_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "events_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.events_resource.id
  http_method = aws_api_gateway_method.events_options_method.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "events_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.events_resource.id
  http_method = aws_api_gateway_method.events_options_method.http_method
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

resource "aws_api_gateway_integration_response" "events_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.events_resource.id
  http_method = aws_api_gateway_method.events_options_method.http_method
  status_code = aws_api_gateway_method_response.events_options_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}