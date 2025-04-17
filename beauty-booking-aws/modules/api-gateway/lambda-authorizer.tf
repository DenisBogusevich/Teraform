# IAM role for the Lambda Authorizer
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

# Create a local archive file if it doesn't exist
resource "local_file" "lambda_authorizer_code" {
  content = <<EOF
// Simple API Gateway Lambda Authorizer for LocalStack
exports.handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // Get the Authorization header
  const authHeader = event.headers ? event.headers.Authorization || event.headers.authorization : null;
  
  // For local development, we'll allow all requests
  // In a real environment, you would validate tokens here
  const userId = 'user123';
  return {
    principalId: userId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn || '*'
        }
      ]
    },
    context: {
      userId: userId,
      environment: '${var.environment}'
    }
  };
};
EOF
  filename = "${path.module}/lambda-functions/index.js"
}

resource "null_resource" "create_zip" {
  depends_on = [local_file.lambda_authorizer_code]

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda-functions && mkdir -p ../tmp && zip -r ../tmp/authorizer.zip index.js && mv ../tmp/authorizer.zip ./"
  }

  triggers = {
    lambda_code = local_file.lambda_authorizer_code.content
  }
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${var.environment}-api-authorizer"
  description   = "Lambda function for API Gateway authorization"
  role          = aws_iam_role.authorizer_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

  # Using the ZIP file created by the null resource
  filename         = "${path.module}/lambda-functions/authorizer.zip"
  source_code_hash = fileexists("${path.module}/lambda-functions/authorizer.zip") ? filebase64sha256("${path.module}/lambda-functions/authorizer.zip") : null

  environment {
    variables = {
      COGNITO_USER_POOL_ID = var.cognito_user_pool
      ENVIRONMENT          = var.environment
    }
  }

  depends_on = [null_resource.create_zip]

  tags = {
    Name        = "${var.environment}-api-authorizer"
    Environment = var.environment
  }
}