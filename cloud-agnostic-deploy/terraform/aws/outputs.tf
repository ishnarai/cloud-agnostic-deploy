# =============================================================================
# outputs.tf (AWS)
# =============================================================================
# Values Terraform prints after `terraform apply` completes. These are also
# readable by other tools (like our GitHub Actions pipeline in Section 8) via
# `terraform output`, letting automation chain Terraform's results into the
# next step (e.g., configuring kubectl to point at the new cluster).

output "cluster_name" {
  description = "Name of the created EKS cluster."
  value       = aws_eks_cluster.orion.name
}

output "cluster_endpoint" {
  description = "API endpoint of the EKS cluster control plane."
  value       = aws_eks_cluster.orion.endpoint
}

output "configure_kubectl_command" {
  description = "Run this command locally to point kubectl at the new cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.orion.name}"
  # This is a nice pattern: Terraform doesn't just tell you WHAT it created,
  # it tells you the EXACT next command to run - reducing the chance of
  # typos or forgotten steps when connecting kubectl afterward.
}
