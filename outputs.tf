# Output values for AKS Private Cluster

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_pvt_cluster.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_pvt_cluster.id
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_pvt_cluster.private_fqdn
}

output "aks_cluster_portal_fqdn" {
  description = "Portal FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_pvt_cluster.portal_fqdn
}

output "aks_node_resource_group" {
  description = "Auto-generated resource group containing AKS cluster resources"
  value       = azurerm_kubernetes_cluster.aks_pvt_cluster.node_resource_group
}

output "aks_cluster_identity" {
  description = "Identity block for the AKS cluster"
  value = {
    type         = azurerm_kubernetes_cluster.aks_pvt_cluster.identity[0].type
    principal_id = azurerm_kubernetes_cluster.aks_pvt_cluster.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.aks_pvt_cluster.identity[0].tenant_id
  }
}

output "aks_kubelet_identity" {
  description = "Kubelet identity for the AKS cluster"
  value = {
    client_id                 = azurerm_kubernetes_cluster.aks_pvt_cluster.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.aks_pvt_cluster.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.aks_pvt_cluster.kubelet_identity[0].user_assigned_identity_id
  }
  sensitive = true
}

# Network Information
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.aks_private_vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.aks_private_vnet.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks_private_subnet.id
}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.appgw.id
}

output "jumpbox_subnet_id" {
  description = "ID of the jumpbox subnet"
  value       = azurerm_subnet.jumpbox.id
}

# Container Registry
output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr_private.name
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.acr_private.login_server
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr_private.id
}

# Key Vault
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.kv_aks_private.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.kv_aks_private.vault_uri
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.kv_aks_private.id
}

# Log Analytics
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.law_aks_private.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.law_aks_private.name
}

output "log_analytics_primary_shared_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.law_aks_private.primary_shared_key
  sensitive   = true
}

# Jumpbox Information
output "jumpbox_public_ip" {
  description = "Public IP address of the jumpbox (if created)"
  value       = var.create_jumpbox ? azurerm_public_ip.aks_jumpbox_pip[0].ip_address : null
}

output "jumpbox_fqdn" {
  description = "FQDN of the jumpbox (if created)"
  value       = var.create_jumpbox ? azurerm_public_ip.aks_jumpbox_pip[0].fqdn : null
}

output "jumpbox_ssh_command" {
  description = "SSH command to connect to jumpbox"
  value       = var.create_jumpbox ? "ssh ${var.jumpbox_admin_username}@${azurerm_public_ip.aks_jumpbox_pip[0].ip_address}" : null
}

# Private DNS Zones
output "private_dns_zone_aks" {
  description = "Private DNS zone for AKS"
  value       = azurerm_private_dns_zone.aks_pvt_dns_zone.name
}

output "private_dns_zone_acr" {
  description = "Private DNS zone for ACR"
  value       = azurerm_private_dns_zone.acr_pvt_dns_zone.name
}

output "private_dns_zone_keyvault" {
  description = "Private DNS zone for Key Vault"
  value       = azurerm_private_dns_zone.kv_pvt_dns_zone.name
}

# kubectl connection command
output "kubectl_config_command" {
  description = "Command to configure kubectl for the AKS cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_private_rg.name} --name ${azurerm_kubernetes_cluster.aks_pvt_cluster.name}"
}

# Network Security Groups
output "aks_nsg_id" {
  description = "ID of the AKS network security group"
  value       = azurerm_network_security_group.nsg_aks.id
}

# User Assigned Identity
output "aks_user_assigned_identity_id" {
  description = "ID of the user assigned identity for AKS"
  value       = azurerm_user_assigned_identity.uai_aks_private.id
}

output "aks_user_assigned_identity_client_id" {
  description = "Client ID of the user assigned identity for AKS"
  value       = azurerm_user_assigned_identity.uai_aks_private.client_id
}

output "aks_user_assigned_identity_principal_id" {
  description = "Principal ID of the user assigned identity for AKS"
  value       = azurerm_user_assigned_identity.uai_aks_private.principal_id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_pvt_cluster.kube_config_raw

  sensitive = true
}
