output "frontend_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "visitor_table_name" {
  description = "DynamoDB table storing the visitor count"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "visitor_lambda_name" {
  description = "Lambda function handling visitor count requests"
  value       = aws_lambda_function.visitor_counter.function_name
}