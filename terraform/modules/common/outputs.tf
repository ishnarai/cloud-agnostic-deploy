# =============================================================================
# modules/common/outputs.tf
# =============================================================================

output "resource_name" {
  description = "A consistent, cloud-prefixed resource name."
  value       = local.resource_name
}

output "common_tags" {
  description = "Standard tags/labels every resource in every cloud should carry."
  value       = local.common_tags
}
