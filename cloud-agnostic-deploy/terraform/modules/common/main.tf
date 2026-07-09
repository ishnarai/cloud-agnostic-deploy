# =============================================================================
# modules/common/main.tf
# =============================================================================
# No actual cloud resources are created here - this module only computes
# consistent values (names, tags) that the aws/azure/gcp configurations each
# reference, so a naming convention change happens in ONE place instead of
# being copy-pasted three times.

locals {
  resource_name = "${var.project_name}-${var.environment}-${var.cloud_provider}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CloudProvider = var.cloud_provider
    ManagedBy   = "terraform"
  }
}
