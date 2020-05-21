terraform {
  # This is enabled to use validation in variable
  experiments = [variable_validation]
}

variable "stage" {
    description = "Stage on which infra should be deployed"
    type = string
    validation {
        condition = can(regex("latest|test|beta|prod|platform", var.stage))
        error_message = "Invalid stage! Allowed values are [latest, test, beta, prod, platform]."
    }
}

variable "tenant" {
    type = string
    default = "platform"
}

variable "feature" {
    type = string
    default = "demo"
}

variable "service" {
    type = string
    default = "demo"
}

output "stage" {
    value = var.stage
}

output "tenant" {
    value = var.tenant
}

output "feature" {
    value = var.feature
}

output "service" {
    value = var.service
}