# =============================================================================
# variables.tf (GCP)
# =============================================================================

variable "gcp_project_id" {
  description = "GCP project ID to deploy resources into. GCP has no sensible default - every project ID is globally unique, so you MUST supply this yourself via terraform.tfvars."
  type        = string
  # Deliberately NO default here - unlike AWS region or Azure resource group
  # name, a GCP project ID is something only you know/own, so forcing you to
  # supply it explicitly prevents accidentally deploying into the wrong
  # (or a nonexistent) project.
}

variable "gcp_region" {
  description = "GCP region to deploy resources into."
  type        = string
  default     = "asia-south1"   # Mumbai region.
}

variable "gcp_zone" {
  description = "GCP zone (a specific data center within the region)."
  type        = string
  default     = "asia-south1-a"
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
  default     = "orion-gke-cluster"
}

variable "node_machine_type" {
  description = "Machine type used for GKE worker nodes."
  type        = string
  default     = "e2-medium"
}

variable "desired_node_count" {
  description = "Number of worker nodes in the GKE node pool."
  type        = number
  default     = 2
}
