resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name        = "${var.project_name}-lambda-errors"
  alarm_description = "Alerts when the visitor counter Lambda reports errors."

  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  statistic   = "Sum"

  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.visitor_counter.function_name
  }

  treat_missing_data = "notBreaching"

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}