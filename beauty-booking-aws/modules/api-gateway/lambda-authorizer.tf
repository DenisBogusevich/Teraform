# Replace the existing aws_lambda_function resource in modules/api-gateway/lambda-authorizer.tf

# Create IAM role for the Lambda Authorizer
resource "aws_iam_role" "authorizer_lambda_role" {
  name = "${var.environment}-api-authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })

  tags = {
    Name        = "${var.environment}-api-authorizer-role"
    Environment = var.environment
  }
}

# Attach basic Lambda execution policy to the role
resource "aws_iam_role_policy_attachment" "authorizer_lambda_basic_execution" {
  role       = aws_iam_role.authorizer_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Add Cognito permission if needed
resource "aws_iam_role_policy" "authorizer_cognito_access" {
  name = "${var.environment}-api-authorizer-cognito-policy"
  role = aws_iam_role.authorizer_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "cognito-idp:DescribeUserPool",
        "cognito-idp:DescribeUserPoolClient",
        "cognito-idp:GetUser",
        "cognito-idp:ListUsers"
      ]
      Resource = "arn:aws:cognito-idp:*:*:userpool/${var.cognito_user_pool}"
      Effect   = "Allow"
    }]
  })
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${var.environment}-api-authorizer"
  description   = "Lambda function for API Gateway authorization"
  role          = aws_iam_role.authorizer_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

  # Use inline code instead of a zip file
  filename      = "${path.module}/lambda-functions/authorizer.zip"

  # Conditional creation based on the existence of the zip file
  # comment this line if you've created the zip file
  source_code_hash = fileexists("${path.module}/lambda-functions/authorizer.zip") ? filebase64sha256("${path.module}/lambda-functions/authorizer.zip") : null

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

# Add this null resource to create a temporary zip file if missing
resource "null_resource" "create_empty_zip" {
  # Only create if the file doesn't exist
  count = fileexists("${path.module}/lambda-functions/authorizer.zip") ? 0 : 1

  # This will execute only once when needed
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${path.module}/lambda-functions
      echo 'exports.handler = async (event) => { return { principalId: "user", policyDocument: { Version: "2012-10-17", Statement: [{ Action: "execute-api:Invoke", Effect: "Allow", Resource: event.methodArn }] } }; };' > /tmp/index.js
      cd /tmp && zip -r authorizer.zip index.js
      mv /tmp/authorizer.zip ${path.module}/lambda-functions/
    EOT
  }
}