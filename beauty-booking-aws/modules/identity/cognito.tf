resource "aws_cognito_user_pool" "main" {
  name = "${var.environment}-beauty-booking-user-pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration   = "OFF"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "user_type"
    attribute_data_type = "String"
    mutable             = true
    required            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 20
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Beauty Booking - Your verification code"
    email_message        = "Your verification code is {####}. Please use this code to verify your account."
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  tags = {
    Name        = "${var.environment}-beauty-booking-user-pool"
    Environment = var.environment
  }
}

resource "aws_cognito_user_pool_client" "web" {
  name                         = "${var.environment}-beauty-booking-web-client"
  user_pool_id                 = aws_cognito_user_pool.main.id
  generate_secret              = false
  refresh_token_validity       = 30
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.environment}BeautyBookingIdentityPool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  tags = {
    Name        = "${var.environment}-beauty-booking-identity-pool"
    Environment = var.environment
  }
}