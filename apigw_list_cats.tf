resource "aws_api_gateway_resource" "categories_resource" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  parent_id   = aws_api_gateway_rest_api.chrono_api.root_resource_id
  path_part   = "categories"
}

resource "aws_api_gateway_method" "categories_method" {
  rest_api_id   = aws_api_gateway_rest_api.chrono_api.id
  resource_id   = aws_api_gateway_resource.categories_resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    # "method.request.querystring.cat_filter" = true
    # "method.request.querystring.num_events" = true
  }
}

resource "aws_api_gateway_integration" "categories_integration" {
  rest_api_id = aws_api_gateway_rest_api.chrono_api.id
  resource_id = aws_api_gateway_resource.categories_resource.id
  http_method = aws_api_gateway_method.categories_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn

  request_parameters = {
    # "integration.request.querystring.cat_filter" = "method.request.querystring.cat_filter"
    # "integration.request.querystring.num_events" = "method.request.querystring.num_events"
  }
}