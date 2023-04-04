

resource "aws_api_gateway_deployment" "hello_world_deployment" {
  depends_on = [aws_api_gateway_integration.hello_world_integration]

  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  stage_name  = "prod"
}

output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.hello_world_deployment.invoke_url}${aws_api_gateway_resource.hello_world_resource.path}"
}

resource "aws_api_gateway_rest_api" "hello_world_api" {
  name        = "hello_world_api"
  description = "API Gateway to trigger hello_world Lambda function"
}

resource "aws_api_gateway_resource" "hello_world_resource" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  parent_id   = aws_api_gateway_rest_api.hello_world_api.root_resource_id
  path_part   = "hello_world"
}

resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id
  resource_id   = aws_api_gateway_resource.hello_world_resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.cat_filter" = true
    "method.request.querystring.num_events" = true
  }
}

resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  resource_id = aws_api_gateway_resource.hello_world_resource.id
  http_method = aws_api_gateway_method.hello_world_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn

  request_parameters = {
    "integration.request.querystring.cat_filter" = "method.request.querystring.cat_filter"
    "integration.request.querystring.num_events" = "method.request.querystring.num_events"
  }
}

