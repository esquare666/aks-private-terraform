# Key Vault for secrets
resource "azurerm_key_vault" "kv_aks_private" {
  name                        = "${var.prefix}-kv"
  location                    = azurerm_resource_group.aks_private_rg.location
  resource_group_name         = azurerm_resource_group.aks_private_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  # Network access rules
  public_network_access_enabled = false

  tags = var.tags
}

# Key Vault access policy for current user/service principal
resource "azurerm_key_vault_access_policy" "kv_access_policy_aks" {
  key_vault_id = azurerm_key_vault.kv_aks_private.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]

  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"
  ]
}

resource "azurerm_private_dns_zone" "kv_pvt_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_pvt_dns_vnet_link" {
  name                  = "${var.prefix}-kv-dns-link"
  resource_group_name   = azurerm_resource_group.aks_private_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_pvt_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.aks_private_vnet.id

  tags = var.tags
}

# Private endpoint for Key Vault
resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${var.prefix}-kv-pe"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name
  subnet_id           = azurerm_subnet.pvt_ep_subnet.id

  private_service_connection {
    name                           = "${var.prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv_aks_private.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_pvt_dns_zone.id]
  }

  tags = var.tags
}
