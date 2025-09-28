# environment values for learning

# Basic Configuration
prefix              = "nz3es-aks"
resource_group_name = "rg-aks-private-learning"
location            = "australiaeast"

# Tags
tags = {
  Environment  = "Learning"
  Project      = "AKS-Private-Cluster"
  Owner        = "Platform-Team"
  ManagedBy    = "Terraform"
  CostCenter   = "IT-Infrastructure"
  BusinessUnit = "Engineering"
}

# Network Configuration
vnet_address_space             = "10.100.0.0/16"
aks_subnet_address_prefix      = "10.100.0.0/24"
appgw_subnet_address_prefix    = "10.100.1.0/24"
firewall_subnet_address_prefix = "10.100.2.0/24"
jumpbox_subnet_address_prefix  = "10.100.3.0/24"
int_lb_subnet_address_prefix   = "10.100.4.0/24"
pvt_link_subnet_address_prefix = "10.100.5.0/24"

# AKS Service Network (separate from VNet)
dns_service_ip = "10.200.0.10"
service_cidr   = "10.200.0.0/16"
pod_cidr       = "10.128.0.0/14"

# Availability Zones (adjust based on region)
availability_zones = ["1", "2", "3"]

# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series?tabs=sizebasic#sizes-in-series
# Error: expanding `default_node_pool`: `max_count`(3) and `min_count`(2) must be set to `null` when `auto_scaling_enabled` is set to `false`
# System Node Pool (for system pods)
system_node_count     = 2
system_node_min_count = 2
system_node_max_count = 3
system_vm_size        = "Standard_D4ds_v5"

# User Node Pool (for application workloads)
user_node_count     = 1
user_node_min_count = 1
user_node_max_count = 3
user_vm_size        = "Standard_D4ds_v4"

# Azure AD Integration
# Get these from: az ad group create --display-name "AKS Administrators" --mail-nickname "aks-admins"
# az ad group list  --query "[].{DisplayName:displayName, ID:id}" -o tsv
# AKS Administrators	32acc71c-3f80-474d-92a8-cade87e96bd3
# Platform Admin	af7c4aee-0e6e-48f8-842e-52d3a6ae4742
aks_admin_group_object_ids = [
  "32acc71c-3f80-474d-92a8-cade87e96bd3",
  "af7c4aee-0e6e-48f8-842e-52d3a6ae4742"
]

# Container Registry
acr_sku = "Premium" # Premium for private endpoints, geo-replication

# Monitoring
log_retention_days = 30 # Increase for compliance requirements

# Jumpbox Configuration
create_jumpbox         = true
jumpbox_admin_username = "azureuser"

# SSH Public Key for Jumpbox (replace with your public key)
# Generate with: ssh-keygen -t rsa -b 4096 -C "test@example.nz"
# Then: cat ~/.ssh/id_rsa.pub
jumpbox_ssh_public_key = "<public-key-for-ssh>"

# Security Configuration
enable_network_policy = true

# Cost Optimization
enable_node_auto_scaling = true
spot_instances_enabled   = false # Set to true for dev/test environments
spot_max_price           = -1    # -1 means pay up to current on-demand price

# Optional: Enable spot instances for user node pool (cost savings)
# spot_instances_enabled = true
# spot_max_price = 0.05  # Maximum price per hour in USDx``

kubernetes_version = "1.32.7"
