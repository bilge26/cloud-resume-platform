data "archive_file" "visitor_lambda" {
  type = "zip"

  source_file = "${path.module}/../backend/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  function_name = "${var.project_name}-visitor-counter"

  role    = aws_iam_role.lambda_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  filename         = data.archive_file.visitor_lambda.output_path
  source_code_hash = data.archive_file.visitor_lambda.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_counter.name
    }
  }

  tags = {
    Name        = "${var.project_name}-visitor-counter"
    Environment = "dev"
    Project     = var.project_name
  }

  depends_on = [
    aws_iam_role_policy.lambda_dynamodb,
    aws_iam_role_policy_attachment.lambda_basic_execution
  ]
}