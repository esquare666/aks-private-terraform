# Azure Container Registry

# User Assigned Identity for ACR
resource "azurerm_user_assigned_identity" "uai_acr_private" {
  name                = "acr-uai-identity"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  tags = var.tags
}

resource "azurerm_container_registry" "acr_private" {
  name                = "nz3es"
  resource_group_name = azurerm_resource_group.aks_private_rg.name
  location            = azurerm_resource_group.aks_private_rg.location
  sku                 = var.acr_sku
  admin_enabled       = false

  # Enable private endpoint
  public_network_access_enabled = false

  data_endpoint_enabled = true

  # Enable vulnerability scanning
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.uai_acr_private.id
    ]
  }

  tags = var.tags
}

# Private DNS Zone for ACR
resource "azurerm_private_dns_zone" "acr_pvt_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_pvt_dns_vnet_link" {
  name                  = "${var.prefix}-acr-dns-link"
  resource_group_name   = azurerm_resource_group.aks_private_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_pvt_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.aks_private_vnet.id

  tags = var.tags
}


# Private endpoints for ACR
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.prefix}-acr-pe"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name
  subnet_id           = azurerm_subnet.pvt_ep_subnet.id

  private_service_connection {
    name                           = "${var.prefix}-acr-psc"
    private_connection_resource_id = azurerm_container_registry.acr_private.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-pvt-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_pvt_dns_zone.id]
  }

  tags = var.tags
}
