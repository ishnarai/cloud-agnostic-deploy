# =============================================================================
# variables.tf (AWS)
# =============================================================================
# Declares INPUTS this Terraform configuration accepts, without hardcoding
# actual values here. Real values are supplied via a terraform.tfvars file
# (gitignored, per Section 2) or -var flags on the command line.

variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "ap-south-1"   # Mumbai region - closest to India for lower latency.
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "orion-eks-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type used for the EKS worker nodes."
  type        = string
  # t3.medium is a small, low-cost instance type appropriate for a PoC.
  # Production workloads would size this based on real CPU/memory needs.
  default     = "t3.medium"
}

variable "desired_node_count" {
  description = "Number of worker nodes in the EKS node group."
  type        = number
  default     = 2
  # Matches the 2 replicas we set in k8s/deployment.yaml, so there's roughly
  # one node available per Pod replica - not a strict requirement, just a
  # sensible PoC default.
}
