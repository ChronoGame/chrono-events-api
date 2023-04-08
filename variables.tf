variable "project_name" {
  type = string
  default = "chrono-events-api"
}

variable "deployment_number" {
  type    = string
  default = "initial"
}

variable "region" {
  type = string
  default = "us-east-1"
}

output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.chrono_deployment.invoke_url}${aws_api_gateway_stage.chrono_stage.stage_name}${aws_api_gateway_resource.events_resource.path}"
}