resource "aws_cloudwatch_log_group" "mercurii_api_lambda" {
  name = "/aws/lambda/mercurii-api"
}

resource "aws_lambda_function" "mercurii_api" {
  function_name = "mercurii-api"
  role          = var.role_arn

  package_type = "Image"
  image_uri    = "${var.image_uri}:latest"

  # tracing_config {
  #   mode = "Active"
  # }

  # environment {
  # }
}

resource "aws_cloudwatch_log_group" "mercurii_api_gateway" {
  name = "/aws/api-gateway/mercurii-api"
}

resource "aws_apigatewayv2_api" "mercurii_api" {
  name          = "mercurii-api"
  protocol_type = "HTTP"

  # cors_configuration {
  #   allow_origins = ["*"]
  # }
}

resource "aws_apigatewayv2_integration" "mercurii_api" {
  api_id = aws_apigatewayv2_api.mercurii_api.id

  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.mercurii_api.invoke_arn

  # payload_format_version = "2.0"
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

data "aws_acm_certificate" "mercurii" {
  domain = "api.mercur-ii.com"
}

resource "aws_apigatewayv2_domain_name" "mercurii" {
  domain_name = "api.mercur-ii.com"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.mercurii.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "mercurii" {
  api_id      = aws_apigatewayv2_api.mercurii_api.id
  domain_name = aws_apigatewayv2_domain_name.mercurii.id
  stage       = aws_apigatewayv2_stage.mercurii_api.id
}

# module "api_gateway" {
#   source = "terraform-aws-modules/apigateway-v2/aws"

#   name          = "mercurii-${var.env}"
#   description   = "Mercurii HTTP API Gateway"
#   protocol_type = "HTTP"

#   create_api_domain_name           = false
#   create_default_stage             = false
#   create_default_stage_api_mapping = true
#   create_routes_and_integrations   = true

#   # Custom domain
#   # domain_name                 = "terraform-aws-modules.modules.tf"
#   # domain_name_certificate_arn = "arn:aws:acm:eu-west-1:052235179155:certificate/2b3a7ed9-05e1-4f9e-952b-27744ba06da6"

#   # Access logs
#   default_stage_access_log_destination_arn = aws_cloudwatch_log_group.mercurii_api_gateway.arn
#   default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

#   target = aws_lambda_function.mercurii.arn
#   # Routes and integrations
#   # integrations = {
#   #   "POST /" = {
#   #     lambda_arn             = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
#   #     payload_format_version = "2.0"
#   #     timeout_milliseconds   = 12000
#   #   }

#   #   "$default" = {
#   #     lambda_arn = aws_lambda_function.mercurii.arn
#   #   }
#   # }

#   tags = {

#   }
# }
