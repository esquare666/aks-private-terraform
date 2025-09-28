# Random password for jumpbox
resource "random_password" "jumpbox_password" {
  length  = 16
  special = true
}

# Jumpbox for private cluster access
resource "azurerm_public_ip" "aks_jumpbox_pip" {
  count               = var.create_jumpbox ? 1 : 0
  name                = "${var.prefix}-jumpbox-pip"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "aks_jumpbox_net" {
  count               = var.create_jumpbox ? 1 : 0
  name                = "${var.prefix}-jumpbox-nic"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.aks_jumpbox_pip[0].id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "aks_jumpbox_vm" {
  count               = var.create_jumpbox ? 1 : 0
  name                = "${var.prefix}-jumpbox"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name
  size                = "Standard_B2s"
  admin_username      = var.jumpbox_admin_username

  # Disable password authentication and use SSH keys only
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.aks_jumpbox_net[0].id,
  ]

  admin_ssh_key {
    username   = var.jumpbox_admin_username
    public_key = var.jumpbox_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" #expected os_disk.0.storage_account_type to be one of ["Premium_LRS" "Standard_LRS" "StandardSSD_LRS" "StandardSSD_ZRS" "Premium_ZRS"], got Premium_SSD
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Custom data to install kubectl and other tools
  custom_data = base64encode(templatefile("${path.module}/jumpbox-init.sh", {
    resource_group_name = azurerm_resource_group.aks_private_rg.name
    aks_cluster_name    = azurerm_kubernetes_cluster.aks_pvt_cluster.name
  }))

  tags = var.tags
}
