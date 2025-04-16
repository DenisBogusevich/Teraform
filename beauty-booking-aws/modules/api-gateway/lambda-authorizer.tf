resource "aws_iam_role" "authorizer_lambda_role" {
  name = "${var.environment}-api-authorizer-role"

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

  tags = {
    Name        = "${var.environment}-api-authorizer-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "authorizer_lambda_policy" {
  name        = "${var.environment}-api-authorizer-policy"
  description = "Policy for API Gateway Lambda Authorizer"

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
      },
      {
        Action = [
          "cognito-idp:AdminGetUser",
          "cognito-idp:GetUser"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "authorizer_lambda_policy_attachment" {
  role       = aws_iam_role.authorizer_lambda_role.name
  policy_arn = aws_iam_policy.authorizer_lambda_policy.arn
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${var.environment}-api-authorizer"
  description   = "Lambda function for API Gateway authorization"
  role          = aws_iam_role.authorizer_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

  filename         = "${path.module}/lambda-functions/authorizer.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-functions/authorizer.zip")

  environment {
    variables = {
      COGNITO_USER_POOL_ID = var.cognito_user_pool
      ENVIRONMENT          = var.environment
    }
  }

  tags = {
    Name        = "${var.environment}-api-authorizer"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "authorizer_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.authorizer.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-api-authorizer-logs"
    Environment = var.environment
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "${var.environment}-cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.authorizer_invoke_role.arn
  type                   = "REQUEST"
  identity_source        = "method.request.header.Authorization"
}

resource "aws_iam_role" "authorizer_invoke_role" {
  name = "${var.environment}-api-auth-invocation-role"

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

  tags = {
    Name        = "${var.environment}-api-auth-invocation-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "authorizer_invoke_policy" {
  name = "${var.environment}-api-auth-invocation-policy"
  role = aws_iam_role.authorizer_invoke_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.authorizer.arn
      }
    ]
  })
}