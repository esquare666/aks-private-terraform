# # Data sources
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# data "azurerm_user_assigned_identity" "webapprouting_uai" {
#   name                = "webapprouting-${azurerm_kubernetes_cluster.aks_pvt_cluster.name}"
#   resource_group_name = "MC_${azurerm_resource_group.aks_private_rg.name}_${azurerm_kubernetes_cluster.aks_pvt_cluster.name}_${azurerm_resource_group.aks_private_rg.location}"

#   depends_on = [
#     azurerm_kubernetes_cluster.aks_pvt_cluster
#   ]
# }

# Random suffix for unique naming
# resource "random_id" "suffix" {
#   byte_length = 4
# }
