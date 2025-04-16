output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_root_resource_id" {
  description = "Resource ID of the API Gateway root"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "${aws_api_gateway_deployment.main.invoke_url}${aws_api_gateway_stage.main.stage_name}"
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "authorizer_id" {
  description = "ID of the API Gateway Authorizer"
  value       = aws_api_gateway_authorizer.cognito.id
}

output "authorizer_lambda_arn" {
  description = "ARN of the Lambda Authorizer"
  value       = aws_lambda_function.authorizer.arn
}

output "api_resources" {
  description = "Map of API Gateway resources"
  value = {
    api       = aws_api_gateway_resource.api.id
    v1        = aws_api_gateway_resource.version.id
    bookings  = aws_api_gateway_resource.bookings.id
    providers = aws_api_gateway_resource.providers.id
    services  = aws_api_gateway_resource.services.id
    payments  = aws_api_gateway_resource.payments.id
    users     = aws_api_gateway_resource.users.id
    health    = aws_api_gateway_resource.health.id
  }
}