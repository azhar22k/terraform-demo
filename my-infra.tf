terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "ais-infra-states"
    key            = "live-demo/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "peak-dev"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "ais-infra-locks"
    encrypt        = true
  }
}
variable "region" {
    description = "AWS region in which Infra will be deployed"
    type = string
    default = "eu-west-1"
}
variable "stage" {}

module "base" {
    source = "github.com/azhar22k/terraform-demo//modules/base?ref=v0.0.1"
    stage = var.stage
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

resource "aws_s3_bucket" "tenant_bucket" {
    bucket = "${module.base.stage}-demo-${module.base.tenant}"
    acl    = "private"
    tags = module.base.tags
}

resource "kubernetes_namespace" "tenant_namespace" {
    metadata {
        labels = module.base.tags
        name = "${module.base.stage}-demo-${module.base.tenant}"
    }
}

output "s3_arn" {
    value = aws_s3_bucket.tenant_bucket.arn
    description = "ARN of S3 bucket"
}

output "ns_uid" {
    value = kubernetes_namespace.tenant_namespace.id
}