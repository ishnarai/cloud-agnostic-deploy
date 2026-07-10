# =============================================================================
# outputs.tf (Azure)
# =============================================================================

output "cluster_name" {
  description = "Name of the created AKS cluster."
  value       = azurerm_kubernetes_cluster.orion.name
}

output "resource_group" {
  description = "Resource Group containing the AKS cluster."
  value       = azurerm_resource_group.orion.name
}

output "configure_kubectl_command" {
  description = "Run this command locally to point kubectl at the new cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.orion.name} --name ${azurerm_kubernetes_cluster.orion.name}"
}
