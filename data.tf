# # Data sources
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Random suffix for unique naming
# resource "random_id" "suffix" {
#   byte_length = 4
# }
