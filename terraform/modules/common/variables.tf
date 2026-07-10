# =============================================================================
# modules/common/variables.tf
# =============================================================================
# Inputs for the shared "common" module - the one piece of Terraform logic
# genuinely identical across all three clouds: consistent resource naming
# and tagging conventions. This is what a "modules/" folder is FOR in
# Terraform - not to fake unification of cloud-specific resources (EKS vs
# AKS vs GKE remain separate, as they must), but to eliminate duplication of
# the small pieces that really are universal.

variable "project_name" {
  description = "Base name used to construct consistent resource names."
  type        = string
  default     = "orion"
}

variable "environment" {
  description = "Deployment environment (e.g. poc, staging, production)."
  type        = string
  default     = "poc"
}

variable "cloud_provider" {
  description = "Which cloud this module invocation is being used from (aws, azure, gcp) - used purely for tagging/labeling, not for branching logic."
  type        = string
}
