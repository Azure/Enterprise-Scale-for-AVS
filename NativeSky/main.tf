data "azurerm_client_config" "current" {}

locals {
  target_resource_names = {
    for key in keys(var.target_vnets) : key => replace(key, "/[^0-9A-Za-z-]/", "-")
  }

  route_table_subnets = merge([
    for vnet_key, vnet in var.target_vnets : {
      for subnet_key, subnet in vnet.subnets : "${vnet_key}.${subnet_key}" => {
        vnet_key   = vnet_key
        subnet_key = subnet_key
        subnet     = subnet
      } if subnet_key != "l2_appliance"
    }
  ]...)

  resource_diagnostic_settings = {
    log_analytics = {
      name                  = "send-to-log-analytics"
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  metrics_diagnostic_settings = {
    log_analytics = {
      name                  = "send-to-log-analytics"
      metric_categories     = ["AllMetrics"]
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  source_vms = merge([
    for vnet_key, vnet in var.target_vnets : {
      for frontend_entry in flatten([
        for subnet_key, subnet in vnet.subnets : [
          for source_vm_key, source_vm in subnet.source_vms : {
            key           = "${subnet_key}.${source_vm_key}"
            subnet_key    = subnet_key
            source_vm_key = source_vm_key
            vm_name       = source_vm.vm_name
            ip_address    = source_vm.ip_address
          }
        ]
      ]) : "${vnet_key}.${frontend_entry.key}" => merge(frontend_entry, { vnet_key = vnet_key })
    }
  ]...)

  vmware_appliance_prefixes = sort(distinct([
    for appliance in values(var.vmware_appliances) : appliance.cidr_prefix
  ]))

  l2_appliance_subnet_prefixes = sort(distinct(flatten([
    for vnet in values(var.target_vnets) : vnet.subnets["l2_appliance"].address_prefixes
  ])))

  vnet_appliance_prefix_rewrite_rules = [
    for vnet_key, vnet in var.target_vnets : {
      name              = "rewrite-${local.target_resource_names[vnet_key]}-to-l2-appliance"
      nextStepIfMatched = "Terminate"
      actions = [
        {
          type = "Replace"
          parameters = [
            {
              routePrefix = sort(vnet.subnets["l2_appliance"].address_prefixes)
            }
          ]
        }
      ]
      matchCriteria = [
        {
          matchCondition = "Equals"
          routePrefix    = sort(tolist(vnet.address_space))
        }
      ]
    }
  ]

  target_virtual_hub_connection_ids = [
    for key, vnet in module.target_vnets :
    "${module.virtual_wan.virtual_hub_resource_ids["primary"]}/hubVirtualNetworkConnections/${coalesce(var.target_vnets[key].virtual_hub_connection.name, "vhub-conn-${vnet.name}")}"
  ]

  expressroute_connection_ids = try(lower(var.avs_private_cloud_connection.generation) == "gen1", false) ? [
    "${module.virtual_wan.ergw_resource_ids_by_hub_key["primary"]}/expressRouteConnections/${var.avs_private_cloud_connection.name}"
  ] : []

  vnet_connection_ids = concat(
    local.target_virtual_hub_connection_ids,
    try(lower(var.avs_private_cloud_connection.generation) == "gen2", false) ? [
      "${module.virtual_wan.virtual_hub_resource_ids["primary"]}/hubVirtualNetworkConnections/${var.avs_private_cloud_connection.name}"
    ] : []
  )
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = var.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                                               = var.log_analytics_workspace_name
  location                                           = var.location
  resource_group_name                                = module.resource_group.name
  log_analytics_workspace_sku                        = "PerGB2018"
  log_analytics_workspace_retention_in_days          = var.log_analytics_workspace_retention_in_days
  log_analytics_workspace_internet_ingestion_enabled = "true"
  log_analytics_workspace_internet_query_enabled     = "true"
  tags                                               = var.tags
  enable_telemetry                                   = var.enable_telemetry
}

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0"

  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = module.resource_group.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  network_acls                  = null
  sku_name                      = "standard"
  tags                          = var.tags
  enable_telemetry              = var.enable_telemetry
  diagnostic_settings           = local.resource_diagnostic_settings

  role_assignments = {
    terraform_secret_writer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
}

module "virtual_wan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm//modules/virtual-wan"
  version = "0.17.2"

  resource_group_name            = module.resource_group.name
  location                       = var.location
  virtual_wan_name               = var.virtual_wan_name
  create_resource_group          = false
  type                           = var.virtual_wan_type
  allow_branch_to_branch_traffic = var.allow_branch_to_branch_traffic
  enable_telemetry               = var.enable_telemetry
  virtual_wan_tags               = var.tags

  virtual_hubs = {
    primary = {
      name                                   = var.virtual_hub_name
      location                               = var.location
      resource_group_name                    = module.resource_group.name
      address_prefix                         = var.virtual_hub_address_prefix
      sku                                    = var.virtual_hub_sku
      hub_routing_preference                 = var.hub_routing_preference
      virtual_router_auto_scale_min_capacity = var.virtual_router_auto_scale_min_capacity
      tags                                   = var.tags
    }
  }

  expressroute_gateways = try(lower(var.avs_private_cloud_connection.generation) == "gen1", false) ? {
    avs = {
      name                          = var.avs_private_cloud_connection.gen1.expressroute_gateway_name
      virtual_hub_key               = "primary"
      scale_units                   = var.avs_private_cloud_connection.gen1.gateway_scale_units
      allow_non_virtual_wan_traffic = var.avs_private_cloud_connection.gen1.allow_non_virtual_wan_traffic
      tags                          = var.tags
    }
  } : {}

  er_circuit_connections = try(lower(var.avs_private_cloud_connection.generation) == "gen1", false) ? {
    avs = {
      name                                 = var.avs_private_cloud_connection.name
      express_route_gateway_key            = "avs"
      express_route_circuit_peering_id     = var.avs_private_cloud_connection.gen1.express_route_circuit_peering_id
      authorization_key                    = nonsensitive(var.avs_expressroute_authorization_key)
      express_route_gateway_bypass_enabled = var.avs_private_cloud_connection.gen1.fast_path_enabled
      enable_internet_security             = var.avs_private_cloud_connection.gen1.internet_security_enabled
      routing_weight                       = var.avs_private_cloud_connection.gen1.routing_weight
    }
  } : {}

  virtual_network_connections = merge(
    {
      for key, vnet in module.target_vnets : "target_${key}" => {
        name = coalesce(
          var.target_vnets[key].virtual_hub_connection.name,
          "vhub-conn-${vnet.name}"
        )
        virtual_hub_key           = "primary"
        remote_virtual_network_id = vnet.resource_id
        internet_security_enabled = var.target_vnets[key].virtual_hub_connection.internet_security_enabled
      }
    },
    try(lower(var.avs_private_cloud_connection.generation) == "gen2", false) ? {
      avs = {
        name                      = var.avs_private_cloud_connection.name
        virtual_hub_key           = "primary"
        remote_virtual_network_id = var.avs_private_cloud_connection.gen2.remote_virtual_network_id
        internet_security_enabled = var.avs_private_cloud_connection.gen2.internet_security_enabled
      }
    } : {}
  )
}

resource "azapi_resource" "expressroute_appliance_route_map" {
  type      = "Microsoft.Network/virtualHubs/routeMaps@2025-05-01"
  name      = "route-map-expressroute-appliance-prefixes"
  parent_id = module.virtual_wan.virtual_hub_resource_ids["primary"]

  body = {
    properties = {
      associatedInboundConnections  = local.expressroute_connection_ids
      associatedOutboundConnections = []
      rules = concat(
        length(local.vmware_appliance_prefixes) > 0 ? [
          {
            name              = "allow-vmware-appliance-prefixes"
            nextStepIfMatched = "Terminate"
            actions           = []
            matchCriteria = [
              {
                matchCondition = "Equals"
                routePrefix    = local.vmware_appliance_prefixes
              }
            ]
          }
        ] : [],
        [
          {
            name              = "drop-other-prefixes"
            nextStepIfMatched = "Terminate"
            actions = [
              {
                type       = "Drop"
                parameters = []
              }
            ]
            matchCriteria = []
          }
        ]
      )
    }
  }

  timeouts {
    create = "90m"
    update = "90m"
  }

  depends_on = [module.virtual_wan]
}

resource "azapi_resource" "vnet_appliance_route_map" {
  type      = "Microsoft.Network/virtualHubs/routeMaps@2025-05-01"
  name      = "route-map-vnet-appliance-prefixes"
  parent_id = module.virtual_wan.virtual_hub_resource_ids["primary"]

  body = {
    properties = {
      associatedInboundConnections  = local.vnet_connection_ids
      associatedOutboundConnections = []
      rules = concat(
        local.vnet_appliance_prefix_rewrite_rules,
        length(local.l2_appliance_subnet_prefixes) > 0 ? [
          {
            name              = "allow-l2-appliance-subnet-prefixes"
            nextStepIfMatched = "Terminate"
            actions           = []
            matchCriteria = [
              {
                matchCondition = "Equals"
                routePrefix    = local.l2_appliance_subnet_prefixes
              }
            ]
          }
        ] : [],
        [
          {
            name              = "drop-other-prefixes"
            nextStepIfMatched = "Terminate"
            actions = [
              {
                type       = "Drop"
                parameters = []
              }
            ]
            matchCriteria = []
          }
        ]
      )
    }
  }

  timeouts {
    create = "90m"
    update = "90m"
  }

  depends_on = [module.virtual_wan]
}

resource "azapi_update_resource" "expressroute_route_map_association" {
  for_each = toset(local.expressroute_connection_ids)

  type        = "Microsoft.Network/expressRouteGateways/expressRouteConnections@2025-05-01"
  resource_id = each.value

  body = {
    properties = {
      routingConfiguration = {
        inboundRouteMap = {
          id = azapi_resource.expressroute_appliance_route_map.id
        }
      }
    }
  }

  timeouts {
    create = "90m"
    update = "90m"
  }

  depends_on = [module.virtual_wan]
}

resource "azapi_update_resource" "vnet_route_map_association" {
  for_each = toset(local.vnet_connection_ids)

  type        = "Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2025-05-01"
  resource_id = each.value

  body = {
    properties = {
      routingConfiguration = {
        inboundRouteMap = {
          id = azapi_resource.vnet_appliance_route_map.id
        }
      }
    }
  }

  timeouts {
    create = "90m"
    update = "90m"
  }

  depends_on = [module.virtual_wan]
}

resource "azurerm_virtual_network" "bastion" {
  name                = var.bastion.virtual_network_name
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.bastion.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "bastion" {
  name                            = "AzureBastionSubnet"
  resource_group_name             = module.resource_group.name
  virtual_network_name            = azurerm_virtual_network.bastion.name
  address_prefixes                = [var.bastion.subnet_address_prefix]
  default_outbound_access_enabled = false
}

resource "azurerm_public_ip" "bastion" {
  name                = var.bastion.public_ip_name
  location            = var.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.bastion.name
  location            = var.location
  resource_group_name = module.resource_group.name
  sku                 = "Standard"
  ip_connect_enabled  = true
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ip-configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  name                       = "send-to-log-analytics"
  target_resource_id         = azurerm_bastion_host.this.id
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

module "target_vnets" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.2"

  for_each = var.target_vnets

  name          = each.value.name
  location      = coalesce(each.value.location, var.location)
  parent_id     = module.resource_group.resource_id
  address_space = each.value.address_space
  dns_servers   = each.value.dns_servers == null ? null : { dns_servers = each.value.dns_servers }
  subnets = merge(each.value.subnets, {
    l2_appliance = merge(each.value.subnets["l2_appliance"], {
      service_endpoints = setunion(
        each.value.subnets["l2_appliance"].service_endpoints,
        ["Microsoft.Storage"],
      )
      nat_gateway = {
        id = azurerm_nat_gateway.appliance[each.key].id
      }
    })
  })
  tags                = merge(var.tags, each.value.tags)
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.resource_diagnostic_settings
}

resource "random_id" "storage_account_suffix" {
  byte_length = 8
}

resource "azurerm_storage_account" "natsky" {
  name                             = "stnatsky${random_id.storage_account_suffix.hex}"
  resource_group_name              = module.resource_group.name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  account_kind                     = "StorageV2"
  access_tier                      = "Hot"
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  shared_access_key_enabled        = true
  public_network_access_enabled    = true
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  tags                             = var.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    virtual_network_subnet_ids = [
      for vnet in module.target_vnets : vnet.subnets["l2_appliance"].resource_id
    ]
  }

  blob_properties {
    versioning_enabled = true

    container_delete_retention_policy {
      days = 7
    }

    delete_retention_policy {
      days = 7
    }
  }
}

resource "azapi_resource" "natsky_blob_container" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01"
  name      = "natsky"
  parent_id = "${azurerm_storage_account.natsky.id}/blobServices/default"

  body = {
    properties = {
      publicAccess = "None"
    }
  }
}

resource "azurerm_user_assigned_identity" "natsky_storage" {
  name                = "id-natsky-storage-${substr(random_id.storage_account_suffix.hex, 0, 8)}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "natsky_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.natsky.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.natsky_storage.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_public_ip" "appliance_nat_gateway" {
  for_each = var.target_vnets

  name                = "pip-nat-${substr(local.target_resource_names[each.key], 0, 72)}"
  location            = coalesce(each.value.location, var.location)
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_nat_gateway" "appliance" {
  for_each = var.target_vnets

  name                    = "nat-${substr(local.target_resource_names[each.key], 0, 76)}"
  location                = coalesce(each.value.location, var.location)
  resource_group_name     = module.resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = merge(var.tags, each.value.tags)
}

resource "azurerm_nat_gateway_public_ip_association" "appliance" {
  for_each = var.target_vnets

  nat_gateway_id       = azurerm_nat_gateway.appliance[each.key].id
  public_ip_address_id = azurerm_public_ip.appliance_nat_gateway[each.key].id
}

removed {
  from = azurerm_subnet_nat_gateway_association.appliance

  lifecycle {
    destroy = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "appliance_nat_gateway" {
  for_each = var.target_vnets

  name                       = "send-to-log-analytics"
  target_resource_id         = azurerm_nat_gateway.appliance[each.key].id
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_virtual_network_peering" "bastion_to_target" {
  for_each = module.target_vnets

  name                         = "peer-bastion-to-${substr(local.target_resource_names[each.key], 0, 63)}"
  resource_group_name          = module.resource_group.name
  virtual_network_name         = azurerm_virtual_network.bastion.name
  remote_virtual_network_id    = each.value.resource_id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "target_to_bastion" {
  for_each = module.target_vnets

  name                         = "peer-${substr(local.target_resource_names[each.key], 0, 63)}-to-bastion"
  resource_group_name          = module.resource_group.name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.bastion.id
  allow_virtual_network_access = true
}

module "target_vnet_virtual_machines" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.21.0"

  for_each = var.target_vnets

  name                = "vm-l2-${local.target_resource_names[each.key]}"
  computer_name       = substr("vm-l2-${local.target_resource_names[each.key]}", 0, 64)
  location            = coalesce(each.value.location, var.location)
  resource_group_name = module.resource_group.name
  zone                = null
  os_type             = "Linux"
  sku_size            = var.virtual_machine_sku
  enable_telemetry    = var.enable_telemetry
  tags                = merge(var.tags, each.value.tags)
  diagnostic_settings = local.metrics_diagnostic_settings

  custom_data = base64encode(templatefile("${path.module}/cloud-init/natsky-azure-appliance.sh.tftpl", {
    storage_account_name       = azurerm_storage_account.natsky.name
    storage_identity_client_id = azurerm_user_assigned_identity.natsky_storage.client_id
    remote_vtep                = var.natsky_remote_vtep
    segments                   = var.natsky_segments
  }))


  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.natsky_storage.id]
  }

  extensions = {
    azure_monitor_agent = {
      name                       = "AzureMonitorLinuxAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorLinuxAgent"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    }
  }

  account_credentials = {
    admin_credentials = {
      username                           = var.virtual_machine_admin_username
      generate_admin_password_or_ssh_key = true
    }
    key_vault_configuration = {
      resource_id = module.key_vault.resource_id
      secret_configuration = {
        name = "vm-l2-${local.target_resource_names[each.key]}-${var.virtual_machine_admin_username}-password"
        tags = merge(var.tags, each.value.tags)
      }
    }
    password_authentication_disabled = false
  }

  network_interfaces = {
    primary = {
      name                  = "nic-l2-${local.target_resource_names[each.key]}"
      is_primary            = true
      ip_forwarding_enabled = true
      diagnostic_settings   = local.metrics_diagnostic_settings
      ip_configurations = {
        primary = {
          name                          = "ipconfig-primary"
          private_ip_subnet_resource_id = module.target_vnets[each.key].subnets["l2_appliance"].resource_id
        }
      }
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "ubuntu-26_04-lts"
    sku       = "server"
    version   = "latest"
  }

  depends_on = [
    module.key_vault,
    azurerm_nat_gateway_public_ip_association.appliance,
    azurerm_role_assignment.natsky_storage_blob_data_contributor,
  ]
}

resource "azurerm_monitor_data_collection_rule" "linux_vm" {
  for_each = var.target_vnets

  name                = "dcr-l2-${local.target_resource_names[each.key]}"
  location            = coalesce(each.value.location, var.location)
  resource_group_name = module.resource_group.name
  kind                = "Linux"
  tags                = merge(var.tags, each.value.tags)

  destinations {
    log_analytics {
      name                  = "log-analytics"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Syslog"]
    destinations = ["log-analytics"]
  }

  data_sources {
    performance_counter {
      name                          = "linux-performance"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "Processor(*)\\% Processor Time",
        "Memory(*)\\Available MBytes Memory",
        "Memory(*)\\% Used Memory",
        "Logical Disk(*)\\% Free Space",
        "Logical Disk(*)\\Disk Transfers/sec",
        "Network(*)\\Total Bytes",
        "System(*)\\Uptime",
      ]
    }

    syslog {
      name           = "linux-syslog"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["*"]
      log_levels     = ["*"]
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "linux_vm" {
  for_each = var.target_vnets

  name                    = "dcra-l2-${local.target_resource_names[each.key]}"
  target_resource_id      = module.target_vnet_virtual_machines[each.key].resource_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux_vm[each.key].id
  description             = "Collect Linux Syslog and performance data from the L2 appliance VM."
}

module "target_vnet_load_balancers" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "0.5.0"

  for_each = var.target_vnets

  name                = "lb-l2-${local.target_resource_names[each.key]}"
  location            = coalesce(each.value.location, var.location)
  resource_group_name = module.resource_group.name
  sku                 = "Standard"
  sku_tier            = "Regional"
  tags                = merge(var.tags, each.value.tags)
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.resource_diagnostic_settings

  frontend_ip_configurations = {
    for source_vm_key, source_vm in local.source_vms : source_vm_key => {
      name                                   = "${source_vm.vm_name}-${replace(source_vm.ip_address, ".", "-")}"
      frontend_private_ip_address            = source_vm.ip_address
      frontend_private_ip_address_allocation = "Static"
      frontend_private_ip_address_version    = "IPv4"
      frontend_private_ip_subnet_resource_id = module.target_vnets[each.key].subnets[source_vm.subnet_key].resource_id
    } if source_vm.vnet_key == each.key
  }

  backend_address_pools = {
    primary = {
      name = "backend-primary"
    }
  }

  backend_address_pool_network_interfaces = {
    primary = {
      backend_address_pool_object_name = "primary"
      ip_configuration_name            = "ipconfig-primary"
      network_interface_resource_id    = module.target_vnet_virtual_machines[each.key].network_interfaces["primary"].id
    }
  }

  lb_probes = {
    primary = {
      name                = "probe-tcp-${var.load_balancer_health_probe_port}"
      protocol            = "Tcp"
      port                = var.load_balancer_health_probe_port
      interval_in_seconds = var.load_balancer_health_probe_interval_seconds
      probe_threshold     = var.load_balancer_health_probe_threshold
    }
  }

  lb_rules = {
    for source_vm_key, source_vm in local.source_vms : source_vm_key => {
      name                              = "ha-ports-${source_vm.vm_name}-${replace(source_vm.ip_address, ".", "-")}"
      frontend_ip_configuration_name    = "${source_vm.vm_name}-${replace(source_vm.ip_address, ".", "-")}"
      backend_address_pool_object_names = ["primary"]
      probe_object_name                 = "primary"
      protocol                          = "All"
      frontend_port                     = 0
      backend_port                      = 0
      enable_floating_ip                = true
      disable_outbound_snat             = true
    } if source_vm.vnet_key == each.key
  }
}

module "target_subnet_route_tables" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.5.0"

  for_each = local.route_table_subnets

  name                          = "rt-${substr("${local.target_resource_names[each.value.vnet_key]}-${replace(each.value.subnet_key, "/[^0-9A-Za-z-]/", "-")}", 0, 77)}"
  location                      = coalesce(var.target_vnets[each.value.vnet_key].location, var.location)
  resource_group_name           = module.resource_group.name
  bgp_route_propagation_enabled = true
  enable_telemetry              = var.enable_telemetry
  tags                          = merge(var.tags, var.target_vnets[each.value.vnet_key].tags)

  subnet_resource_ids = {
    associated = module.target_vnets[each.value.vnet_key].subnets[each.value.subnet_key].resource_id
  }

  routes = merge(
    {
      default = {
        name                   = "default-via-ilb"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = var.target_vnets[each.value.vnet_key].subnets[each.value.subnet_key].source_vms[sort(keys(var.target_vnets[each.value.vnet_key].subnets[each.value.subnet_key].source_vms))[0]].ip_address
      }
    },
    merge([
      for subnet_key, subnet in var.target_vnets[each.value.vnet_key].subnets : {
        for prefix_index, address_prefix in subnet.address_prefixes : "${subnet_key}.${prefix_index}" => {
          name                   = "to-${substr(replace(subnet_key, "/[^0-9A-Za-z-]/", "-"), 0, 60)}-${prefix_index}"
          address_prefix         = address_prefix
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = var.target_vnets[each.value.vnet_key].subnets[each.value.subnet_key].source_vms[sort(keys(var.target_vnets[each.value.vnet_key].subnets[each.value.subnet_key].source_vms))[0]].ip_address
        }
      } if subnet_key != each.value.subnet_key
    ]...)
  )
}

resource "azurerm_monitor_diagnostic_setting" "virtual_hub" {
  name                       = "send-to-log-analytics"
  target_resource_id         = module.virtual_wan.virtual_hub_resource_ids["primary"]
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "expressroute_gateway" {
  for_each = try(lower(var.avs_private_cloud_connection.generation) == "gen1", false) ? { avs = true } : {}

  name                       = "send-to-log-analytics"
  target_resource_id         = module.virtual_wan.ergw_resource_ids_by_hub_key["primary"]
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

  enabled_metric {
    category = "AllMetrics"
  }
}

