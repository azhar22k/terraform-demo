variable "region" {
    description = "AWS region in which Infra will be deployed"
    type = string
    default = "eu-west-1"
}
variable "stage" {
  default = "platform"
}

module "base" {
    source = "../base"
    stage = var.stage
}

provider "aws" {
    version = "~> 2.62"
    profile = "peak-dev"
    region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "ais-infra-states"
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
  name         = "ais-infra-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = module.base.tags
}