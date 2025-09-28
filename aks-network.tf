# Virtual Network
resource "azurerm_virtual_network" "aks_private_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  tags = var.tags
}

## Subnets
# AKS Subnet
resource "azurerm_subnet" "aks_private_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.aks_private_rg.name
  virtual_network_name = azurerm_virtual_network.aks_private_vnet.name
  address_prefixes     = [var.aks_subnet_address_prefix]

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}

# Application Gateway Subnet (for future ingress)
resource "azurerm_subnet" "appgw" {
  name                 = "${var.prefix}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.aks_private_rg.name
  virtual_network_name = azurerm_virtual_network.aks_private_vnet.name
  address_prefixes     = [var.appgw_subnet_address_prefix]
}

# Azure Firewall Subnet
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet" # Must be exact name
  resource_group_name  = azurerm_resource_group.aks_private_rg.name
  virtual_network_name = azurerm_virtual_network.aks_private_vnet.name
  address_prefixes     = [var.firewall_subnet_address_prefix]
}

# Jumpbox Subnet (for management access)
resource "azurerm_subnet" "jumpbox" {
  name                 = "${var.prefix}-jumpbox-subnet"
  resource_group_name  = azurerm_resource_group.aks_private_rg.name
  virtual_network_name = azurerm_virtual_network.aks_private_vnet.name
  address_prefixes     = [var.jumpbox_subnet_address_prefix]
}

# Internal LoadBalancer Subnet
resource "azurerm_subnet" "aks_int_lb_subnet" {
  name                 = "${var.prefix}-int-lb-subnet"
  resource_group_name  = azurerm_resource_group.aks_private_rg.name
  virtual_network_name = azurerm_virtual_network.aks_private_vnet.name
  address_prefixes     = [var.int_lb_subnet_address_prefix]
}

# Subnet for Private Endpoint Subnet
resource "azurerm_subnet" "pvt_ep_subnet" {
  name                 = "pvt-ep-subnet"
  resource_group_name  = azurerm_resource_group.aks_private_rg.name
  virtual_network_name = azurerm_virtual_network.aks_private_vnet.name
  address_prefixes     = [var.pvt_link_subnet_address_prefix]

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}

## Private DNS and endpoint
# Private DNS Zone for AKS
resource "azurerm_private_dns_zone" "aks_pvt_dns_zone" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  tags = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "aks_pvt_dns_zone_virt_net_link" {
  name                  = "${var.prefix}-dns-link"
  resource_group_name   = azurerm_resource_group.aks_private_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_pvt_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.aks_private_vnet.id

  tags = var.tags
}

# Network Security Group for AKS Subnet
# A number between 100 and 4096. Rules are processed in priority order, with lower numbers processed before higher numbers because lower numbers have higher priority.
resource "azurerm_network_security_group" "nsg_aks" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  # Allow inbound from Application Gateway subnet
  security_rule {
    name                       = "AllowAppGwInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = var.appgw_subnet_address_prefix
    destination_address_prefix = var.aks_subnet_address_prefix
  }

  # Allow inbound from jumpbox subnet for management
  security_rule {
    name                       = "AllowJumpboxInbound"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.jumpbox_subnet_address_prefix
    destination_address_prefix = var.aks_subnet_address_prefix
  }

  # Deny all other inbound traffic
  # security_rule {
  #   name                       = "DenyAllInbound"
  #   priority                   = 4000
  #   direction                  = "Inbound"
  #   access                     = "Deny"
  #   protocol                   = "*"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  tags = var.tags
}

# Associate NSG with AKS Subnet
resource "azurerm_subnet_network_security_group_association" "aks_subnet_associate_nsg" {
  subnet_id                 = azurerm_subnet.aks_private_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_aks.id
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "aks_pvt_apps_dns_zone" {
  name                = "3es.com"
  resource_group_name = azurerm_resource_group.aks_private_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_pvt_apps_dns_zone_virt_net_link" {
  name                  = "${var.prefix}-apps-dns-link"
  resource_group_name   = azurerm_resource_group.aks_private_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_pvt_apps_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.aks_private_vnet.id
  registration_enabled  = true # Optional: Enable auto-registration
}

### Jumpbox
# Network Security Group for Jumpbox Subnet
# A number between 100 and 4096. Rules are processed in priority order, with lower numbers processed before higher numbers because lower numbers have higher priority.
resource "azurerm_network_security_group" "nsg_jumpbox" {
  name                = "${var.prefix}-nsg-jumpbox"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  # Allow inbound from all to Jumphost, port 22
  security_rule {
    name                       = "AllowAppGwInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "Internet"
    destination_address_prefix = var.jumpbox_subnet_address_prefix
  }

  tags = var.tags
}

# Associate NSG with AKS Subnet
resource "azurerm_subnet_network_security_group_association" "jumpbox_subnet_associate_nsg" {
  subnet_id                 = azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.nsg_jumpbox.id
}
