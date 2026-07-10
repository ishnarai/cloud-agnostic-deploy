# =============================================================================
# main.tf (Azure)
# =============================================================================
# Provisions a minimal AKS (Azure Kubernetes Service) cluster that our
# k8s/deployment.yaml and k8s/service.yaml can be applied to unmodified.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "common" {
  source         = "../modules/common"
  cloud_provider = "azure"
}

resource "azurerm_resource_group" "orion" {
  name     = var.resource_group_name
  location = var.azure_region
  tags     = module.common.common_tags
}

# -----------------------------------------------------------------------------
# The AKS cluster itself
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "orion" {
  name                = var.cluster_name
  location            = azurerm_resource_group.orion.location
  resource_group_name  = azurerm_resource_group.orion.name
  dns_prefix          = "orion-aks"
  # dns_prefix becomes part of the cluster's auto-generated DNS name for its
  # API server - AKS requires this, EKS/GKE don't have an equivalent field.

  default_node_pool {
    name       = "default"
    node_count = var.desired_node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
    # Unlike AWS's explicit IAM roles we hand-wrote, Azure's "SystemAssigned"
    # managed identity tells Azure to automatically create and manage the
    # identity AKS needs to talk to other Azure resources - less boilerplate
    # than AWS's IAM role/policy attachment dance, but functionally similar
    # in purpose: "give the cluster permission to manage cloud resources."
  }
}
