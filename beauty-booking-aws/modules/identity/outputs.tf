output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_app_client_id" {
  description = "ID of the Cognito App Client"
  value       = aws_cognito_user_pool_client.web.id
}

output "cognito_identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.main.id
}

output "authenticated_role_arn" {
  description = "ARN of the authenticated role"
  value       = aws_iam_role.authenticated.arn
}

output "unauthenticated_role_arn" {
  description = "ARN of the unauthenticated role"
  value       = aws_iam_role.unauthenticated.arn
}