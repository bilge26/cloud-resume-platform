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

output "visitor_api_url" {
  description = "Public URL of the visitor counter API"
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/visitors"
}

output "cloudfront_domain_name" {
  description = "CloudFront domain serving the frontend"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_url" {
  description = "Public HTTPS URL of the Cloud Resume frontend"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution serving the frontend"
  value       = aws_cloudfront_distribution.frontend.id
}

output "terraform_state_bucket_name" {
  description = "S3 bucket storing the remote Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}