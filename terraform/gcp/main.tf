# =============================================================================
# main.tf (GCP)
# =============================================================================
# Provisions a minimal GKE (Google Kubernetes Engine) cluster that our
# k8s/deployment.yaml and k8s/service.yaml can be applied to unmodified.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "common" {
  source         = "../modules/common"
  cloud_provider = "gcp"
}

# -----------------------------------------------------------------------------
# The GKE cluster itself
# -----------------------------------------------------------------------------
resource "google_container_cluster" "orion" {
  name     = var.cluster_name
  location = var.gcp_zone
  # Using a ZONE (not the whole region) creates a cheaper "zonal" cluster
  # (single control plane) rather than a "regional" cluster (control plane
  # replicated across multiple zones) - a reasonable cost/complexity
  # trade-off for a PoC; production would likely use a regional cluster
  # for higher availability.

  # GKE, unusually, creates a DEFAULT node pool automatically unless you
  # tell it not to. We remove the default pool and define our own explicitly
  # below (google_container_node_pool) - this gives us full control over
  # node count/machine type, matching how we did it for AWS and Azure.
  remove_default_node_pool = true
  initial_node_count       = 1

  resource_labels = module.common.common_tags
}

# -----------------------------------------------------------------------------
# The node pool - the actual VMs that will run our Pods
# -----------------------------------------------------------------------------
resource "google_container_node_pool" "orion_nodes" {
  name       = "${var.cluster_name}-node-pool"
  cluster    = google_container_cluster.orion.name
  location   = var.gcp_zone
  node_count = var.desired_node_count

  node_config {
    machine_type = var.node_machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      # Grants the node pool's service account broad API access - a
      # simplification appropriate for a PoC. Production would scope this
      # down to only the specific APIs needed (least-privilege principle).
    ]
  }
}
