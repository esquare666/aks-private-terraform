# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law_aks_private" {
  name                = "${var.prefix}-log-analytics"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# User Assigned Identity for AKS
resource "azurerm_user_assigned_identity" "uai_aks_private" {
  name                = "${var.prefix}-pvt-uai-identity"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  tags = var.tags
}

# Role assignment for AKS identity to manage network resources
# Make sure the automation account (SP) has Role Based Access Control Administrator RBAC in the resource group or subscription level
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_virtual_network.aks_private_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.uai_aks_private.principal_id
}

# Role assignment for AKS identity to manage DNS
resource "azurerm_role_assignment" "aks_dns_contributor" {
  scope                = azurerm_private_dns_zone.aks_pvt_dns_zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.uai_aks_private.principal_id
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_pvt_cluster" {
  name                = "${var.prefix}-pvt-learning"
  location            = azurerm_resource_group.aks_private_rg.location
  resource_group_name = azurerm_resource_group.aks_private_rg.name

  # Default node pool
  default_node_pool {
    name       = "system"
    os_sku     = "Ubuntu"
    zones      = var.availability_zones
    node_count = var.system_node_count
    vm_size    = var.system_vm_size

    # Auto-scaling
    auto_scaling_enabled = true
    min_count            = var.system_node_min_count
    max_count            = var.system_node_max_count


    vnet_subnet_id = azurerm_subnet.aks_private_subnet.id

    # Security configurations - Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule
    only_critical_addons_enabled = true

    # Node configuration
    max_pods        = 30
    os_disk_size_gb = 128
    os_disk_type    = "Ephemeral" # default_node_pool.0.os_disk_type to be one of ["Ephemeral" "Managed"], got Premium_SSD

    # Node labels
    node_labels = {
      "nodepool"    = "system"
      "environment" = "learning"
    }

    upgrade_settings {
      drain_timeout_in_minutes      = 10
      node_soak_duration_in_minutes = 0
      max_surge                     = "33%"
    }
  }

  # dns_prefix                 = "${var.prefix}-pvt-learning-dns" #DNS name prefix # You must define either a dns_prefix or a dns_prefix_private_cluster field.
  dns_prefix_private_cluster = "prefix"

  # Auto-upgrade
  automatic_upgrade_channel = "patch"

  # Azure AD integration
  azure_active_directory_role_based_access_control {
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = var.aks_admin_group_object_ids
    azure_rbac_enabled     = false
  }

  # Security configurations
  azure_policy_enabled = true

  cost_analysis_enabled = true

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai_aks_private.id]
  }

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 24 #expected image_cleaner_interval_hours to be in the range (24 - 2160)

  # key_management_service {
  #   key_vault_key_id         = ""
  #   key_vault_network_access = "Private"
  # }

  # Key Vault integration
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m"
  }

  kubernetes_version = var.kubernetes_version

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.jumpbox_ssh_public_key
    }
  }
  local_account_disabled = true

  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [1, 3]
    }
  }

  # maintenance_window_auto_upgrade {
  #   duration    = 4
  #   frequency   = "AbsoluteMonthly"
  #   day_of_week = "Saturday"
  #   interval    = 1
  # }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  oidc_issuer_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law_aks_private.id
  }

  private_cluster_enabled           = true
  private_dns_zone_id               = azurerm_private_dns_zone.aks_pvt_dns_zone.id
  workload_identity_enabled         = true
  role_based_access_control_enabled = true
  sku_tier                          = "Standard"

  storage_profile {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  support_plan = "KubernetesOfficial"

  tags = var.tags

  # upgrade_override {
  #   force_upgrade_enabled = "false"
  # }

  web_app_routing {
    dns_zone_ids             = [azurerm_private_dns_zone.aks_pvt_apps_dns_zone.id]
    default_nginx_controller = "AnnotationControlled"
  }

  # only for Public API Server
  # api_server_access_profile {
  #   authorized_ip_ranges = ["public.ip (xx.xx.xx.xx)"]
  # }

  # These role assigned in Subscription level
  depends_on = [
    azurerm_role_assignment.aks_network_contributor,
    azurerm_role_assignment.aks_dns_contributor,
  ]
}

# User node pool for applications
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_pvt_cluster.id
  vm_size               = var.user_vm_size
  zones                 = var.availability_zones
  vnet_subnet_id        = azurerm_subnet.aks_private_subnet.id

  # Auto-scaling configuration
  auto_scaling_enabled = true
  # `max_count` and `min_count` must be set to `null` when auto_scaling_enabled is set to `false`
  min_count  = var.user_node_min_count
  max_count  = var.user_node_max_count
  node_count = var.user_node_count

  # Node configuration
  max_pods        = 30
  os_disk_size_gb = 128
  os_disk_type    = "Ephemeral" # expected os_disk_type to be one of ["Ephemeral" "Managed"], got Premium_SSD
  os_type         = "Linux"

  #   # Taints for user workloads
  #   node_taints = [
  #     "workload=user:NoSchedule"
  #   ]

  # Node labels
  node_labels = {
    "nodepool" = "user"
    "workload" = "applications"
  }

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags
}

# Role assignment for ACR pull
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr_private.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_pvt_cluster.kubelet_identity[0].object_id
}

# Role assignment for Private DNS Zone Contributor for DNS entries to manage - Ingress hostnames to manage
resource "azurerm_role_assignment" "aks_webapprouting_dns_contributor" {
  scope                = azurerm_private_dns_zone.aks_pvt_dns_zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_pvt_cluster.web_app_routing[0].web_app_routing_identity[0].object_id
  # principal_id         = data.azurerm_user_assigned_identity.webapprouting_uai.principal_id
}
