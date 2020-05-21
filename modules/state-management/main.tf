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

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${module.base.stage}-ais-terraform-state"
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = module.base.tags
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${module.base.stage}-ais-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = module.base.tags
}