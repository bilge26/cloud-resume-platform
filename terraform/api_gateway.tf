resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "${var.project_name}-visitor-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["content-type"]
  }

  tags = {
    Name        = "${var.project_name}-visitor-api"
    Environment = "dev"
    Project     = var.project_name
  }
}

resource "aws_apigatewayv2_integration" "visitor_lambda" {
  api_id = aws_apigatewayv2_api.visitor_api.id

  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.visitor_counter.invoke_arn
  integration_method = "POST"

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "visitor_count" {
  api_id = aws_apigatewayv2_api.visitor_api.id

  route_key = "GET /visitors"

  target = "integrations/${aws_apigatewayv2_integration.visitor_lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.visitor_api.id

  name        = "$default"
  auto_deploy = true

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}