resource "aws_cloudwatch_log_group" "mercurii_api_lambda" {
  name = "/aws/lambda/mercurii-api"
}

resource "aws_lambda_function" "mercurii_api" {
  function_name = "mercurii-api"
  role          = var.role_arn

  package_type = "Image"
  image_uri    = "${var.image_uri}:latest"

  vpc_config {
    security_group_ids = var.lambda_security_groups
    subnet_ids         = var.lambda_subnets
  }

  environment {
    variables = {
      "POSTGRES_HOST"     = var.db_address
      "POSTGRES_PORT"     = var.db_port
      "POSTGRES_DB"       = var.db_name
      "POSTGRES_USER"     = var.db_username
      "POSTGRES_PASSWORD" = var.db_password
    }
  }
}

resource "aws_cloudwatch_log_group" "mercurii_api_gateway" {
  name = "/aws/api-gateway/mercurii-api"
}

resource "aws_apigatewayv2_api" "mercurii_api" {
  name          = "mercurii-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_allowed_origins
    allow_methods = ["*"]
    allow_headers = ["*"]
  }

  disable_execute_api_endpoint = true
}

resource "aws_apigatewayv2_integration" "mercurii_api" {
  api_id = aws_apigatewayv2_api.mercurii_api.id

  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.mercurii_api.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "mercurii_api" {
  api_id    = aws_apigatewayv2_api.mercurii_api.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.mercurii_api.id}"
}

resource "aws_apigatewayv2_stage" "mercurii_api" {
  api_id = aws_apigatewayv2_api.mercurii_api.id
  name   = var.env

  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.mercurii_api_gateway.arn
    format          = "$context.identity.sourceIp,$context.requestTime,$context.httpMethod,$context.routeKey,$context.protocol,$context.status,$context.responseLength,$context.requestId,$context.path,$context.integrationErrorMessage"
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mercurii_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.mercurii_api.execution_arn}/*"
}

resource "aws_apigatewayv2_api_mapping" "mercurii" {
  api_id      = aws_apigatewayv2_api.mercurii_api.id
  domain_name = var.api_domain_name
  stage       = aws_apigatewayv2_stage.mercurii_api.id
}
