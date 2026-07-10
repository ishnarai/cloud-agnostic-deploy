# =============================================================================
# variables.tf (Azure)
# =============================================================================

variable "azure_region" {
  description = "Azure region to deploy resources into."
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group that will contain all resources."
  type        = string
  default     = "orion-rg"
  # NOTE: Azure has a concept AWS/GCP don't have as explicitly - a
  # "Resource Group" is a logical container for related resources. Everything
  # we create below lives inside this one Resource Group, which makes cleanup
  # trivial: deleting the Resource Group deletes everything inside it.
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "orion-aks-cluster"
}

variable "node_vm_size" {
  description = "VM size used for AKS worker nodes."
  type        = string
  default     = "Standard_B2s"
  # A small, low-cost burstable VM size appropriate for a PoC.
}

variable "desired_node_count" {
  description = "Number of worker nodes in the AKS default node pool."
  type        = number
  default     = 2
}
