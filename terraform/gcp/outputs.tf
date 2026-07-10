# =============================================================================
# outputs.tf (GCP)
# =============================================================================

output "cluster_name" {
  description = "Name of the created GKE cluster."
  value       = google_container_cluster.orion.name
}

output "cluster_endpoint" {
  description = "API endpoint of the GKE cluster control plane."
  value       = google_container_cluster.orion.endpoint
}

output "configure_kubectl_command" {
  description = "Run this command locally to point kubectl at the new cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.orion.name} --zone ${var.gcp_zone} --project ${var.gcp_project_id}"
}
