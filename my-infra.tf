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
variable "tenant" {
    description = "Generated resources will {stage}-demo-{tenant}"
    type = string
}
provider "aws" {
    version = "~> 2.62"
    profile = "peak-dev"
    region = var.region
}

provider "kubernetes" {
    version = "~> 1.11"
    config_context = "dev"
}

locals {
    tags = {
        stage = var.stage
        tenant = "platform"
        feature = "demo"
        service = "demo"
    }
}
resource "aws_s3_bucket" "tenant_bucket" {
  bucket = "${var.stage}-demo-${var.tenant}"
  acl    = "private"
  tags = local.tags
}

resource "kubernetes_namespace" "tenant_namespace" {
  metadata {
    labels = local.tags
    name = "${var.stage}-demo-${var.tenant}"
  }
}

output "s3_arn" {
    value = aws_s3_bucket.tenant_bucket.arn
    description = "ARN of S3 bucket"
}

output "ns_uid" {
    value = kubernetes_namespace.tenant_namespace.id
}