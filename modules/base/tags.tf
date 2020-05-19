locals {
    tags = {
        stage = var.stage
        tenant = var.tenant
        feature = var.feature
        service = var.service
    }
}

output "tags" {
    value = local.tags
}