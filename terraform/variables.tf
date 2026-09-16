variable "aws_region" {
  description = "AWS region used for the Cloud Resume infrastructure"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name used for Cloud Resume resources"
  type        = string
  default     = "bilge-cloud-resume"
}