# =============================================================================
# main.tf (AWS)
# =============================================================================
# Provisions a minimal EKS (Elastic Kubernetes Service) cluster that our
# k8s/deployment.yaml and k8s/service.yaml can be applied to unmodified.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # Pinning the provider version (like pinning requirements.txt) ensures
      # this configuration behaves identically regardless of when/where
      # `terraform init` is run.
    }
  }
}

# The "provider" block configures WHICH cloud and region Terraform talks to.
# This is the ONE line that fundamentally can't be "cloud-agnostic" - it's
# the deliberate, isolated exception discussed in Section 1.
provider "aws" {
  region = var.aws_region
}

# Shared naming/tagging module - the one piece of logic genuinely identical
# across all three clouds (see terraform/modules/common).
module "common" {
  source         = "../modules/common"
  cloud_provider = "aws"
}

# -----------------------------------------------------------------------------
# Networking - for a PoC, we reuse the AWS account's default VPC instead of
# creating a brand new one. This is a deliberate simplification: a real
# production setup would define its own VPC, subnets, and route tables for
# proper network isolation. We call this out explicitly rather than pretending
# this is production-grade networking.
# -----------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------------------------------------------------------
# IAM role that EKS itself (the control plane) assumes to manage AWS
# resources on your behalf (like creating load balancers for Services).
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  # "assume_role_policy" defines WHO/WHAT is allowed to use this role.
  # Here, we say "the EKS service itself is allowed to assume this role."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  # This AWS-managed policy grants the minimum permissions EKS's control
  # plane needs to function - using AWS's managed policy instead of writing
  # our own is the recommended, lower-maintenance approach.
}

# -----------------------------------------------------------------------------
# The EKS cluster itself (the Kubernetes control plane)
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "orion" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  tags = module.common.common_tags

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  # Terraform usually infers dependencies automatically from references
  # (e.g., using aws_iam_role_policy_attachment's output somewhere), but here
  # we depend on the POLICY being attached, not just the role existing, so
  # we declare it explicitly to guarantee correct ordering.
}

# -----------------------------------------------------------------------------
# IAM role for the WORKER NODES (the actual EC2 instances running our Pods)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  # Allows worker nodes to PULL our Docker image from ECR (AWS's container
  # registry) - required for our Pods to actually start.
}

# -----------------------------------------------------------------------------
# The managed node group - the actual EC2 instances that will run our Pods
# -----------------------------------------------------------------------------
resource "aws_eks_node_group" "orion_nodes" {
  cluster_name    = aws_eks_cluster.orion.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.aws_subnets.default.ids

  scaling_config {
    desired_size = var.desired_node_count
    max_size     = var.desired_node_count + 1
    min_size     = 1
  }

  instance_types = [var.node_instance_type]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly,
  ]
}
