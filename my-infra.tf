variable "region" {
    description = "AWS region in which Infra will be deployed"
    type = string
    default = "eu-west-1"
}
variable "stage" {}

module "base" {
    source = "./modules/base"
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
    depends_on = [module.base]
    bucket = "${module.base.stage}-demo-${module.base.tenant}"
    acl    = "private"
    tags = module.base.tags
}

resource "kubernetes_namespace" "tenant_namespace" {
    depends_on = [module.base]
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