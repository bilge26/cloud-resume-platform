terraform {
  required_version = ">= 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0"
    }
  }
  backend "s3" {
    bucket       = "bilge-cloud-resume-tfstate-f299b7234b0c90b1c4f7cce723"
    key          = "cloud-resume/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}