variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to create."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  type        = string
  description = "The Azure region in which to create all resources."

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "virtual_wan_name" {
  type        = string
  description = "The name of the Virtual WAN."

  validation {
    condition     = length(trimspace(var.virtual_wan_name)) > 0
    error_message = "virtual_wan_name must not be empty."
  }
}

variable "virtual_hub_name" {
  type        = string
  description = "The name of the Virtual Hub."

  validation {
    condition     = length(trimspace(var.virtual_hub_name)) > 0
    error_message = "virtual_hub_name must not be empty."
  }
}

variable "virtual_hub_address_prefix" {
  type        = string
  description = "The address prefix assigned to the Virtual Hub. A /23 CIDR block is recommended."

  validation {
    condition     = can(cidrnetmask(var.virtual_hub_address_prefix))
    error_message = "virtual_hub_address_prefix must be a valid IPv4 CIDR block."
  }
}

variable "virtual_wan_type" {
  type        = string
  description = "The Virtual WAN type."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.virtual_wan_type)
    error_message = "virtual_wan_type must be Basic or Standard."
  }
}

variable "virtual_hub_sku" {
  type        = string
  description = "The Virtual Hub SKU."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.virtual_hub_sku)
    error_message = "virtual_hub_sku must be Basic or Standard."
  }
}

variable "hub_routing_preference" {
  type        = string
  description = "The Virtual Hub routing preference."
  default     = "ExpressRoute"

  validation {
    condition     = contains(["ASPath", "ExpressRoute", "VpnGateway"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be ASPath, ExpressRoute, or VpnGateway."
  }
}

variable "virtual_router_auto_scale_min_capacity" {
  type        = number
  description = "The minimum routing infrastructure units for the Virtual Hub router."
  default     = 2

  validation {
    condition     = var.virtual_router_auto_scale_min_capacity >= 2
    error_message = "virtual_router_auto_scale_min_capacity must be at least 2."
  }
}

variable "allow_branch_to_branch_traffic" {
  type        = bool
  description = "Whether branch-to-branch traffic is allowed through the Virtual WAN."
  default     = true
}

variable "bastion" {
  type = object({
    name                          = string
    virtual_network_name          = string
    virtual_network_address_space = list(string)
    subnet_address_prefix         = string
    public_ip_name                = string
  })
  description = "Configuration for the Azure Bastion host and its dedicated VNet and subnet. The Bastion VNet is peered with every target VNet."

  validation {
    condition = alltrue([
      length(trimspace(var.bastion.name)) > 0,
      length(trimspace(var.bastion.virtual_network_name)) > 0,
      length(trimspace(var.bastion.public_ip_name)) > 0,
      length(var.bastion.virtual_network_address_space) > 0,
      alltrue([for address_prefix in var.bastion.virtual_network_address_space : can(cidrnetmask(address_prefix))]),
      can(cidrnetmask(var.bastion.subnet_address_prefix)),
      try(tonumber(split("/", var.bastion.subnet_address_prefix)[1]) <= 26, false),
    ])
    error_message = "Bastion names must not be empty, VNet and subnet prefixes must be valid IPv4 CIDRs, and AzureBastionSubnet must be /26 or larger."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "enable_telemetry" {
  type        = bool
  description = "Controls telemetry for the Azure Verified Modules."
  default     = true
}

variable "key_vault_name" {
  type        = string
  description = "The globally unique name of the Key Vault used to store generated VM administrator passwords."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "key_vault_name must be 3-24 alphanumeric or hyphen characters, begin and end with an alphanumeric character, and be globally unique."
  }
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "The name of the Log Analytics workspace that receives resource diagnostic logs and metrics."

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{2,61}[A-Za-z0-9]$", var.log_analytics_workspace_name))
    error_message = "log_analytics_workspace_name must be 4-63 alphanumeric or hyphen characters and begin and end with an alphanumeric character."
  }
}

variable "log_analytics_workspace_retention_in_days" {
  type        = number
  description = "The number of days that the Log Analytics workspace retains data."
  default     = 30

  validation {
    condition     = var.log_analytics_workspace_retention_in_days >= 30 && var.log_analytics_workspace_retention_in_days <= 730
    error_message = "log_analytics_workspace_retention_in_days must be between 30 and 730."
  }
}

variable "virtual_machine_sku" {
  type        = string
  description = "The SKU to use for each target VNet virtual machine."
  default     = "Standard_D2s_v5"

  validation {
    condition     = length(trimspace(var.virtual_machine_sku)) > 0
    error_message = "virtual_machine_sku must not be empty."
  }
}

variable "virtual_machine_admin_username" {
  type        = string
  description = "The administrator username for each target VNet virtual machine."
  default     = "azureuser"

  validation {
    condition     = length(trimspace(var.virtual_machine_admin_username)) > 0
    error_message = "virtual_machine_admin_username must not be empty."
  }
}

variable "natsky_remote_vtep" {
  type        = string
  description = "The VMware appliance underlay IPv4 address used as the remote VXLAN VTEP by every Azure appliance VM."
  default     = "10.0.113.10"

  validation {
    condition     = can(cidrnetmask("${var.natsky_remote_vtep}/32"))
    error_message = "natsky_remote_vtep must be a valid IPv4 address."
  }
}

variable "natsky_segments" {
  type = map(object({
    vni                 = number
    cidr                = string
    gateway             = string
    namespace_name      = string
    bridge_name         = string
    veth_root_name      = string
    veth_namespace_name = string
    bridge_ip           = string
    namespace_ip        = string
    apipa_address       = string
    policy_table        = number
  }))
  description = "NatSky segment configurations keyed by the systemd controller instance label."
  default = {
    seg12 = {
      vni                 = 10100
      cidr                = "12.12.12.0/24"
      gateway             = "12.12.12.1"
      namespace_name      = "ns-12-12-12-0-24"
      bridge_name         = "br-seg12"
      veth_root_name      = "veth-seg12-rt"
      veth_namespace_name = "veth-seg12-ns"
      bridge_ip           = "169.254.1.2/30"
      namespace_ip        = "169.254.1.1/30"
      apipa_address       = "169.254.0.2/16"
      policy_table        = 200
    }
    seg13 = {
      vni                 = 10101
      cidr                = "13.13.13.0/24"
      gateway             = "13.13.13.1"
      namespace_name      = "ns-13-13-13-0-24"
      bridge_name         = "br-seg13"
      veth_root_name      = "veth-seg13-rt"
      veth_namespace_name = "veth-seg13-ns"
      bridge_ip           = "169.254.2.2/30"
      namespace_ip        = "169.254.2.1/30"
      apipa_address       = "169.254.0.3/16"
      policy_table        = 201
    }
  }

  validation {
    condition = length(var.natsky_segments) > 0 && alltrue([
      for label, segment in var.natsky_segments :
      can(regex("^[0-9A-Za-z_-]+$", label)) &&
      segment.vni >= 1 && segment.vni <= 16777215 &&
      can(cidrnetmask(segment.cidr)) &&
      can(cidrnetmask("${segment.gateway}/32")) &&
      can(cidrnetmask(segment.bridge_ip)) &&
      can(cidrnetmask(segment.namespace_ip)) &&
      can(cidrnetmask(segment.apipa_address)) &&
      segment.policy_table >= 1 && segment.policy_table <= 4294967295
    ])
    error_message = "Each NatSky segment must use a safe label, VNI 1-16777215, valid IPv4 CIDRs and gateway, and a valid policy table number."
  }

  validation {
    condition     = length(distinct([for segment in values(var.natsky_segments) : segment.vni])) == length(var.natsky_segments) && length(distinct([for segment in values(var.natsky_segments) : segment.policy_table])) == length(var.natsky_segments)
    error_message = "NatSky segment VNI and policy_table values must be unique."
  }
}

variable "load_balancer_health_probe_port" {
  type        = number
  description = "The TCP port used to health probe each target VNet VM. Defaults to the Ubuntu SSH service."
  default     = 22

  validation {
    condition     = var.load_balancer_health_probe_port >= 1 && var.load_balancer_health_probe_port <= 65535
    error_message = "load_balancer_health_probe_port must be between 1 and 65535."
  }
}

variable "load_balancer_health_probe_interval_seconds" {
  type        = number
  description = "The interval in seconds between Load Balancer health probes."
  default     = 5

  validation {
    condition     = var.load_balancer_health_probe_interval_seconds >= 5 && var.load_balancer_health_probe_interval_seconds <= 120
    error_message = "load_balancer_health_probe_interval_seconds must be between 5 and 120."
  }
}

variable "load_balancer_health_probe_threshold" {
  type        = number
  description = "The number of consecutive health probe results required to change backend health state."
  default     = 2

  validation {
    condition     = var.load_balancer_health_probe_threshold >= 1 && var.load_balancer_health_probe_threshold <= 100
    error_message = "load_balancer_health_probe_threshold must be between 1 and 100."
  }
}

variable "target_vnets" {
  type = map(object({
    name          = string
    location      = optional(string, null)
    address_space = set(string)
    dns_servers   = optional(list(string), null)
    subnets = optional(map(object({
      name                                          = string
      address_prefixes                              = list(string)
      default_outbound_access_enabled               = optional(bool, false)
      private_endpoint_network_policies             = optional(string, "Enabled")
      private_link_service_network_policies_enabled = optional(bool, true)
      service_endpoints                             = optional(set(string), [])
      source_vms = optional(map(object({
        vm_name    = string
        ip_address = string
      })), {})
    })), {})
    virtual_hub_connection = optional(object({
      name                      = optional(string, null)
      internet_security_enabled = optional(bool, false)
    }), {})
    tags = optional(map(string), {})
  }))
  description = "A map of target virtual networks, subnet configurations, and optional Virtual Hub connection settings. Every target VNet is connected to the primary Virtual Hub."
  default     = {}

  validation {
    condition = alltrue([
      for vnet in values(var.target_vnets) :
      length(trimspace(vnet.name)) > 0 && alltrue([
        for address_prefix in vnet.address_space : can(cidrnetmask(address_prefix))
      ])
    ])
    error_message = "Each target VNet must have a non-empty name and valid IPv4 CIDR address spaces."
  }

  validation {
    condition = alltrue(flatten([
      for vnet in values(var.target_vnets) : [
        for subnet in values(vnet.subnets) : alltrue([
          for address_prefix in subnet.address_prefixes : can(cidrnetmask(address_prefix))
        ])
      ]
    ]))
    error_message = "Each target VNet subnet address prefix must be a valid IPv4 CIDR block."
  }

  validation {
    condition = alltrue([
      for vnet in values(var.target_vnets) : contains(keys(vnet.subnets), "l2_appliance")
    ])
    error_message = "Each target VNet must define a subnet using the l2_appliance map key."
  }

  validation {
    condition = alltrue(flatten([
      for vnet in values(var.target_vnets) : [
        for subnet_key, subnet in vnet.subnets : subnet_key == "l2_appliance" || (
          length(subnet.source_vms) > 0 && alltrue([
            for source_vm in values(subnet.source_vms) :
            length(trimspace(source_vm.vm_name)) > 0 &&
            can(cidrnetmask("${source_vm.ip_address}/32"))
          ])
        )
      ]
    ]))
    error_message = "Each non-l2_appliance subnet must define at least one source_vms entry, each with a non-empty vm_name and a valid IPv4 address."
  }
}

variable "vmware_appliances" {
  type = map(object({
    name        = string
    cidr_prefix = string
  }))
  description = "VMware appliances whose CIDR prefixes may be advertised inbound from ExpressRoute connections."
  default     = {}

  validation {
    condition = alltrue([
      for appliance in values(var.vmware_appliances) :
      length(trimspace(appliance.name)) > 0 && can(cidrnetmask(appliance.cidr_prefix))
    ])
    error_message = "Each VMware appliance must have a non-empty name and a valid IPv4 CIDR prefix."
  }
}

variable "avs_private_cloud_connection" {
  type = object({
    generation = string
    name       = string
    gen1 = optional(object({
      expressroute_gateway_name        = string
      express_route_circuit_peering_id = string
      gateway_scale_units              = optional(number, 1)
      allow_non_virtual_wan_traffic    = optional(bool, false)
      fast_path_enabled                = optional(bool, true)
      internet_security_enabled        = optional(bool, false)
      routing_weight                   = optional(number, 0)
    }), null)
    gen2 = optional(object({
      remote_virtual_network_id = string
      internet_security_enabled = optional(bool, false)
    }), null)
  })
  description = "Optional connection from the primary Virtual Hub to an AVS private cloud. Gen1 uses ExpressRoute; Gen2 uses a Virtual Network connection."
  default     = null

  validation {
    condition = var.avs_private_cloud_connection == null || contains(
      ["gen1", "gen2"],
      lower(var.avs_private_cloud_connection.generation)
    )
    error_message = "avs_private_cloud_connection.generation must be gen1 or gen2."
  }

  validation {
    condition = var.avs_private_cloud_connection == null || (
      lower(var.avs_private_cloud_connection.generation) == "gen1"
      ? var.avs_private_cloud_connection.gen1 != null && var.avs_private_cloud_connection.gen2 == null
      : var.avs_private_cloud_connection.gen2 != null && var.avs_private_cloud_connection.gen1 == null
    )
    error_message = "Configure exactly one matching branch: gen1 for generation gen1, or gen2 for generation gen2."
  }

  validation {
    condition = var.avs_private_cloud_connection == null || try(
      var.avs_private_cloud_connection.gen1.gateway_scale_units >= 1 &&
      var.avs_private_cloud_connection.gen1.routing_weight >= 0 &&
      var.avs_private_cloud_connection.gen1.routing_weight <= 32000,
      true
    )
    error_message = "Gen1 gateway_scale_units must be at least 1 and routing_weight must be between 0 and 32000."
  }
}

variable "avs_expressroute_authorization_key" {
  type        = string
  description = "The authorization key for the AVS Gen1 ExpressRoute circuit connection. Required when generation is gen1."
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition = try(lower(var.avs_private_cloud_connection.generation) != "gen1", true) || (
      var.avs_expressroute_authorization_key != null && length(trimspace(var.avs_expressroute_authorization_key)) > 0
    )
    error_message = "avs_expressroute_authorization_key is required for an AVS Gen1 connection."
  }
}