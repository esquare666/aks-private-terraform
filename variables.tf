variable "location" {
  description = "NZ3ES Azure Location"
  type        = string
  default     = "australiaeast"
}

variable "azure_tenant_id" {
  default = ""
}

variable "nz3es_subscription_paygo" {
  description = "NZ3ES Pay and Go Subscription"
  type        = string
  default     = ""
}

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  default     = "868359e0-e5eb-461d-97cc-a0335123211c"
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
  default     = ""
}

variable "learning_subscription" {
  description = "NZ3ES Pay and Go Subscription"
  type        = string
  default     = ""
}

##### Variables for AKS Private Cluster

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "aks-private"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-private"
}


variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Sandbox"
    Project     = "AKS-Private"
    Owner       = "Platform-Team"
    ManagedBy   = "Terraform"
  }
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "appgw_subnet_address_prefix" {
  description = "Address prefix for Application Gateway subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "firewall_subnet_address_prefix" {
  description = "Address prefix for Azure Firewall subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "jumpbox_subnet_address_prefix" {
  description = "Address prefix for jumpbox subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "int_lb_subnet_address_prefix" {
  description = "Address prefix for Internal Load Balancer"
  type        = string
  default     = "10.0.5.0/24"
}

variable "pvt_link_subnet_address_prefix" {
  description = "Address prefix for Private Link"
  type        = string
  default     = "10.0.6.0/24"
}

variable "dns_service_ip" {
  description = "DNS service IP for AKS"
  type        = string
  default     = "10.1.0.10"
}

variable "service_cidr" {
  description = "Service CIDR for AKS"
  type        = string
  default     = "10.1.0.0/16"
}

variable "pod_cidr" {
  description = "POD CIDR for AKS"
  type        = string
  default     = "10.235.0.0/14"
}

# AKS Configuration
variable "availability_zones" {
  description = "Availability zones for AKS nodes"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# System Node Pool Configuration
variable "system_node_count" {
  description = "Initial number of system nodes"
  type        = number
  default     = 3
}

variable "system_node_min_count" {
  description = "Minimum number of system nodes"
  type        = number
  default     = 3
}

variable "system_node_max_count" {
  description = "Maximum number of system nodes"
  type        = number
  default     = 5
}

variable "system_vm_size" {
  description = "VM size for system nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

# User Node Pool Configuration
variable "user_node_count" {
  description = "Initial number of user nodes"
  type        = number
  default     = 3
}

variable "user_node_min_count" {
  description = "Minimum number of user nodes"
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "Maximum number of user nodes"
  type        = number
  default     = 10
}

variable "user_vm_size" {
  description = "VM size for user nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

# Azure AD Integration
variable "aks_admin_group_object_ids" {
  description = "Object IDs of Azure AD groups that should have admin access to AKS"
  type        = list(string)
  default     = []
}

# Container Registry
variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

# Monitoring
variable "log_retention_days" {
  description = "Log Analytics workspace retention in days, expected retention_in_days to be in the range (30 - 730)"
  type        = number
  default     = 30
}

# Jumpbox Configuration
variable "create_jumpbox" {
  description = "Whether to create a jumpbox VM for private cluster access"
  type        = bool
  default     = true
}

variable "jumpbox_admin_username" {
  description = "Admin username for jumpbox VM"
  type        = string
  default     = "azureuser"
}

variable "jumpbox_ssh_public_key" {
  description = "SSH public key for jumpbox VM access"
  type        = string
  default     = ""
  sensitive   = true
}

# Security Configuration
variable "enable_pod_security_policy" {
  description = "Enable Pod Security Policy (deprecated, use Azure Policy instead)"
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  description = "Enable Kubernetes Network Policy"
  type        = bool
  default     = true
}

# Cost Management
variable "enable_node_auto_scaling" {
  description = "Enable auto-scaling for node pools"
  type        = bool
  default     = true
}

variable "spot_instances_enabled" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Maximum price for spot instances (-1 for market price)"
  type        = number
  default     = -1
}

variable "kubernetes_version" {
  description = "Version of K8S"
  type        = string
  default     = "1.33.2"
}
