terraform {
  # This is enabled to use validation in variable
  experiments = [variable_validation]
}

variable "region" {
    description = "AWS region in which Infra will be deployed"
    type = string
    default = "eu-west-1"
}

variable "stage" {
    description = "Stage on which infra should be deployed"
    type = string
    validation {
        condition = can(regex("latest|test|beta|prod", var.stage))
        error_message = "Invalid stage! Allowed values are [latest, test, beta, prod]."
    }
}
variable "bucket_postfix" {
    description = "Generated Buckename will {stage}-demo{postfix}"
    type = string
    default = ""
}
provider "aws" {
    version = "~> 2.62"
    profile = "peak-dev"
    region = var.region
}

locals {
    tags = {
        stage = var.stage
        tenant = "platform"
        feature = "demo"
        service = "demo"
    }
}
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.stage}-demo${var.bucket_postfix}"
  acl    = "private"
  tags = local.tags
}

output "s3_arn" {
    value = aws_s3_bucket.bucket.arn
    description = "ARN of S3 bucket"
}