# Azure Virtual WAN, Hub, Bastion, VNets, and VMs Terraform Module

## How to deploy this module with Terraform

The files in this directory form a complete Terraform root module. Follow these
steps from a Bash-compatible terminal to create the Azure resources. Terraform
keeps a state file that records what it manages, so always run future Terraform
commands from the same working directory and preserve the state securely.

### 1. Install the prerequisites

Before starting, install:

- [Terraform](https://developer.hashicorp.com/terraform/install) version 1.11 or
  later, but earlier than 2.0.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).
- Access to an Azure subscription. The signed-in identity must be able to create
  the resources in this module and assign Azure roles. The `Owner` role is the
  simplest option; alternatively, use `Contributor` together with `User Access
  Administrator` at the deployment scope.

Confirm that the tools are installed:

```bash
terraform version
az version
```

### 2. Sign in and select an Azure subscription

```bash
az login
az account list --output table
az account set --subscription "<subscription-name-or-id>"
az account show --output table
```

The last command shows the subscription Terraform will use. If the subscription
belongs to a specific Microsoft Entra tenant, sign in with
`az login --tenant "<tenant-id>"`.

### 3. Prepare the deployment values

From the repository root, change to this directory and copy the example values:

```bash
cd NativeSky
cp sample.auto.tfvars.sample local.tfvars
```

Open `local.tfvars` and replace the example names, Azure region, IP address
ranges, target VNets, and AVS resource IDs with values for your environment.
Azure Key Vault names must be globally unique. Make sure none of the configured
CIDR ranges overlap.

The sample enables the Gen1 AVS connection. Before deploying, configure exactly
one of the following:

- **Gen1:** Keep the Gen1 block, set its ExpressRoute private peering resource
  ID, and provide a newly generated authorization key through the environment as
  shown below.
- **Gen2:** Comment out the Gen1 block and uncomment/configure the Gen2 block.
- **No AVS connection:** Comment out both connection blocks.

For Gen1, remove `avs_expressroute_authorization_key` from `local.tfvars` and set
it only in the current shell:

```bash
export TF_VAR_avs_expressroute_authorization_key='<authorization-key>'
```

Do not commit `local.tfvars`, saved plan files, `.terraform/`, or Terraform state
files. Variable files, plans, and state can contain sensitive values.

### 4. Initialize and check the configuration

Initialization downloads the required providers and Azure Verified Modules:

```bash
terraform init
terraform fmt -check
terraform validate
```

Run `terraform init -upgrade` instead only when you intentionally want Terraform
to select newer provider or module versions allowed by the configuration.

### 5. Review the deployment plan

```bash
terraform plan -var-file="local.tfvars" -out="native-sky.tfplan"
```

Read the plan carefully. Confirm the subscription, region, resource names,
address ranges, and number of resources before continuing. Creating the Virtual
Hub route maps can take about 30 minutes, and the deployed Azure resources incur
charges.

### 6. Apply the reviewed plan to create the infrastructure

```bash
terraform apply "native-sky.tfplan"
```

Terraform prints progress and exits when the deployment succeeds or reports an
error. During this pre-release, the appliance binaries are not publicly
available. This first apply creates the private `natsky` blob container, but the
appliance VMs cannot finish their cloud-init bootstrap until the supplied
appliance archive is uploaded manually. Terraform may report a successful apply
even though cloud-init did not find the archive.

Keep the generated state files in this directory, or configure a secure [remote
backend](https://developer.hashicorp.com/terraform/language/backend) for shared
or production use. Do not edit the state manually.

### 7. Upload the pre-release appliance archive

Obtain the pre-release appliance archive (tar files) from the project team. Its blob name
must contain `azure-appliance`, because cloud-init uses that text to locate the
newest matching artifact in the `natsky` container. The archive must retain the
format and directory structure supplied by the project team.

Find the generated storage account name in the resource group:

```bash
STORAGE_ACCOUNT_NAME=$(az storage account list \
  --resource-group "<resource-group-name>" \
  --query "[?starts_with(name, 'stnatsky')].name | [0]" \
  --output tsv)

echo "$STORAGE_ACCOUNT_NAME"
```

The storage firewall permits the appliance subnets and denies other networks.
Upload the archive from an allowed network, or temporarily add the public IP of
your workstation before uploading it:

```bash
MY_PUBLIC_IP=$(curl --silent https://api.ipify.org)

az storage account network-rule add \
  --resource-group "<resource-group-name>" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --ip-address "$MY_PUBLIC_IP"

az storage blob upload \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --container-name "natsky" \
  --name "<azure-appliance-archive-name>" \
  --file "/path/to/<azure-appliance-archive-name>" \
  --auth-mode key \
  --overwrite
```

The signed-in identity must be allowed to list the storage account keys when
using `--auth-mode key`. Wait a few minutes after adding the network rule if the
upload is initially rejected. The next Terraform apply restores the storage
firewall to the configuration declared by this module and removes the temporary
workstation rule.

### 8. Rebuild the appliance VMs

Uploading a blob does not itself change the Terraform configuration, and
cloud-init normally runs only when a VM is first created. Create a new plan that
explicitly replaces each appliance VM so its bootstrap runs again and can
download the uploaded archive. Add one `-replace` argument for every key in
`target_vnets`. For the `application` and `shared_services` keys in the sample
configuration, run:

```bash
terraform plan -var-file="local.tfvars" \
  -replace='module.target_vnet_virtual_machines["application"]' \
  -replace='module.target_vnet_virtual_machines["shared_services"]' \
  -out="native-sky-appliances.tfplan"

terraform apply "native-sky-appliances.tfplan"
```

Review the replacement plan before applying it. Substitute the keys from your
own `target_vnets` map and omit any example key that is not present. After the
apply completes, the replacement VMs download the newest matching archive from
the `natsky` container and perform the appliance installation.

To make later changes, edit `local.tfvars`, then repeat the `terraform plan` and
`terraform apply` steps. Terraform will propose only the differences from its
recorded state.

### 9. Remove the deployment when it is no longer needed

First review everything Terraform will delete:

```bash
terraform plan -destroy -var-file="local.tfvars"
terraform destroy -var-file="local.tfvars"
```

Type `yes` only after confirming that the listed resources can be removed. A
destroy operation is permanent and may remove data stored by this deployment.


## Module Details

Creates an Azure resource group, Virtual WAN, Virtual Hub, a dedicated Azure
Bastion VNet, and a map of target virtual networks. The Bastion VNet contains
only the required `AzureBastionSubnet` and is directly peered in both directions
with every target VNet. The module enables IP-based connections to targets and
deploys one Ubuntu 26.04 Linux virtual machine in each
target VNet's `l2_appliance` subnet. Each target VNet also receives a Standard
internal Load Balancer with a private frontend for each configured source VM and an HA Ports rule
with floating IP enabled for every explicitly configured frontend, and the VNet's
VM in its backend pool. Each non-appliance subnet defines one or more static
frontends with VM names and private IPs; frontend names use
`<vm_name>-<dashed-ip>`. A dedicated
Standard NAT Gateway and public IP provide outbound connectivity
for each `l2_appliance` subnet. The `Microsoft.Storage` service endpoint is enabled
on every appliance subnet. A globally unique StorageV2 account permits network
access only from those appliance subnets and contains a private `natsky` blob
container. A shared user-assigned managed identity is attached to every appliance
VM and receives `Storage Blob Data Contributor` access to the account. Shared-key
authorization is enabled, while anonymous blob access remains disabled. VM administrator passwords
are generated by the VM AVM and stored as
secrets in an Azure Key Vault. The module uses Azure Verified Modules (AVM) for
its foundational resources and AzureRM resources for supporting configuration.
A Log Analytics workspace collects all available resource logs and metrics from
the Key Vault, Virtual Hub, Bastion host, target VNets, VMs, NICs, Load
Balancers, and an optional Gen1 ExpressRoute gateway. Each VM also has the Azure
Monitor Agent and a regional Data Collection Rule that sends Linux Syslog and
performance counters to the workspace. It can also temporarily connect an Azure
VMware Solution private cloud using ExpressRoute for Gen1 or a Virtual Hub VNet
connection for Gen2.

Every subnet except `l2_appliance` receives a route table. Each table routes
`0.0.0.0/0` and every sibling subnet prefix through the internal Load Balancer
frontend located in the associated subnet. Because an Azure route has one next
hop IP, the route uses the `source_vms` entry with the lexically first map key.
The primary Virtual Hub has separate inbound route maps for ExpressRoute and
VNet connections. The ExpressRoute map permits only prefixes in
`vmware_appliances`. For each target VNet, the VNet map replaces an advertised
full VNet address-space prefix with that VNet's `l2_appliance` subnet prefix. It
also permits directly advertised `l2_appliance` prefixes unchanged. Both maps
drop every other inbound advertisement.

## Usage

```hcl
provider "azurerm" {
  features {}
}

module "virtual_wan" {
  source = "./path/to/this/module"

  resource_group_name        = "rg-connectivity-prod-eastus"
  location                   = "eastus"
  virtual_wan_name           = "vwan-prod-eastus"
  virtual_hub_name           = "vhub-prod-eastus"
  virtual_hub_address_prefix = "10.0.0.0/23"
  key_vault_name             = "kv-connectivity-prod-eus"
  log_analytics_workspace_name = "log-connectivity-prod-eus"

  bastion = {
    name                          = "bas-connectivity-prod-eus"
    virtual_network_name          = "vnet-bastion-prod-eastus"
    virtual_network_address_space = ["10.30.0.0/24"]
    subnet_address_prefix         = "10.30.0.0/26"
    public_ip_name                = "pip-bas-connectivity-prod-eus"
  }

  target_vnets = {
    application = {
      name          = "vnet-application-prod-eastus"
      address_space = ["10.10.0.0/16"]

      virtual_hub_connection = {
        name                      = "vhub-conn-application"
        internet_security_enabled = false
      }

      subnets = {
        application = {
          name             = "snet-application"
          address_prefixes = ["10.10.0.0/24"]
          source_vms = {
            primary = {
              vm_name    = "vm-l2-application"
              ip_address = "10.10.0.4"
            }
          }
        }
        l2_appliance = {
          name              = "snet-l2-appliance"
          address_prefixes  = ["10.10.1.0/24"]
          service_endpoints = ["Microsoft.Storage"]
        }
      }
    }
  }

  vmware_appliances = {
    primary = {
      name        = "avs-primary"
      cidr_prefix = "10.20.0.0/22"
    }
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

The calling configuration must authenticate the AzureRM and AzAPI providers.
For local development, Azure CLI authentication can be used after running
`az login`. Workload identity or a service principal is recommended for CI/CD.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | `>= 1.11, < 2.0` |
| AzureRM provider | `~> 4.0` |
| AzAPI provider | `~> 2.12` |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region for all resources | `string` | n/a | yes |
| `virtual_wan_name` | Virtual WAN name | `string` | n/a | yes |
| `virtual_hub_name` | Virtual Hub name | `string` | n/a | yes |
| `virtual_hub_address_prefix` | Virtual Hub IPv4 CIDR; `/23` recommended | `string` | n/a | yes |
| `virtual_wan_type` | Virtual WAN type: `Basic` or `Standard` | `string` | `"Standard"` | no |
| `virtual_hub_sku` | Virtual Hub SKU: `Basic` or `Standard` | `string` | `"Standard"` | no |
| `hub_routing_preference` | Hub routing preference | `string` | `"ExpressRoute"` | no |
| `virtual_router_auto_scale_min_capacity` | Minimum hub routing infrastructure units | `number` | `2` | no |
| `allow_branch_to_branch_traffic` | Allow branch-to-branch traffic | `bool` | `true` | no |
| `bastion` | Azure Bastion host, dedicated VNet, `/26` or larger subnet, and public IP configuration; the VNet is peered with every target VNet | `object` | n/a | yes |
| `key_vault_name` | Globally unique Key Vault name used for generated VM passwords | `string` | n/a | yes |
| `log_analytics_workspace_name` | Log Analytics workspace receiving resource diagnostics | `string` | n/a | yes |
| `log_analytics_workspace_retention_in_days` | Workspace data retention in days | `number` | `30` | no |
| `virtual_machine_sku` | SKU used for each target VNet virtual machine | `string` | `"Standard_D2s_v5"` | no |
| `virtual_machine_admin_username` | Administrator username for each target VNet VM | `string` | `"azureuser"` | no |
| `load_balancer_health_probe_port` | TCP port used to probe each target VNet VM | `number` | `22` | no |
| `load_balancer_health_probe_interval_seconds` | Seconds between health probes | `number` | `5` | no |
| `load_balancer_health_probe_threshold` | Consecutive probe results required to change backend health | `number` | `2` | no |
| `target_vnets` | Target VNets keyed by stable instance name, with address spaces, optional subnet settings, and Virtual Hub connection settings | `map(object)` | `{}` | no |
| `vmware_appliances` | VMware appliances keyed by stable name, with a display name and IPv4 CIDR prefix allowed inbound from ExpressRoute connections | `map(object)` | `{}` | no |
| `avs_private_cloud_connection` | Optional AVS connection with a mutually exclusive `gen1` or `gen2` configuration | `object` | `null` | no |
| `avs_expressroute_authorization_key` | Sensitive AVS Gen1 ExpressRoute authorization key | `string` | `null` | Gen1 only |
| `tags` | Tags applied to all resources | `map(string)` | `{}` | no |
| `enable_telemetry` | Enable AVM telemetry | `bool` | `true` | no |

## Outputs

| Name | Description |
| --- | --- |
| `resource_group_id` | Resource group resource ID |
| `resource_group_name` | Resource group name |
| `key_vault_id` | Key Vault resource ID |
| `key_vault_name` | Key Vault name |
| `log_analytics_workspace_id` | Log Analytics workspace resource ID |
| `log_analytics_workspace_name` | Log Analytics workspace name |
| `virtual_wan_id` | Virtual WAN resource ID |
| `virtual_wan_name` | Virtual WAN name |
| `virtual_hub_id` | Virtual Hub resource ID |
| `virtual_hub_name` | Virtual Hub name |
| `bastion_id` | Azure Bastion host resource ID |
| `bastion_name` | Azure Bastion host name |
| `bastion_virtual_network_id` | Dedicated Bastion VNet resource ID |
| `bastion_subnet_id` | `AzureBastionSubnet` resource ID |
| `bastion_public_ip_address` | Public IPv4 address assigned to Bastion |
| `bastion_to_target_peering_ids` | Bastion-to-target peering IDs keyed by target VNet key |
| `target_to_bastion_peering_ids` | Target-to-Bastion peering IDs keyed by target VNet key |
| `target_vnet_ids` | Target VNet IDs keyed by input map key |
| `target_vnet_names` | Target VNet names keyed by input map key |
| `target_vnet_subnets` | Target VNet subnet outputs keyed by input map key |
| `target_vnet_hub_connection_names` | Virtual Hub connection names keyed by target VNet key |
| `appliance_nat_gateway_ids` | Appliance subnet NAT Gateway IDs keyed by target VNet key |
| `appliance_nat_gateway_public_ip_ids` | NAT Gateway public IP IDs keyed by target VNet key |
| `appliance_nat_gateway_public_ip_addresses` | NAT Gateway public IPv4 addresses keyed by target VNet key |
| `appliance_subnet_nat_gateway_association_ids` | Appliance subnet NAT Gateway association IDs keyed by target VNet key |
| `target_virtual_machine_ids` | VM resource IDs keyed by target VNet key |
| `target_virtual_machine_names` | VM names keyed by target VNet key |
| `target_virtual_machine_network_interfaces` | VM network interface outputs keyed by target VNet key |
| `target_virtual_machine_data_collection_rule_ids` | Azure Monitor DCR IDs keyed by target VNet key |
| `target_virtual_machine_data_collection_rule_association_ids` | VM-to-DCR association IDs keyed by target VNet key |
| `target_load_balancer_ids` | Internal Load Balancer IDs keyed by target VNet key |
| `target_load_balancer_frontend_ip_configurations` | Internal frontend configurations keyed by target VNet key |
| `target_load_balancer_backend_pools` | Backend pools keyed by target VNet key |
| `target_subnet_route_table_ids` | Route table IDs keyed as `<vnet_key>.<subnet_key>` |
| `target_subnet_routes` | Route outputs keyed as `<vnet_key>.<subnet_key>` |
| `avs_connection_generation` | Configured AVS generation, or `null` |
| `avs_expressroute_gateway_id` | Gen1 Virtual Hub ExpressRoute gateway ID, or `null` |

## Azure VMware Solution Connectivity

Only one AVS generation branch can be configured at a time.

The Virtual Hub uses two strict inbound allowlists. The ExpressRoute route map
permits prefixes listed in `vmware_appliances` and is applied to the configured
Gen1 ExpressRoute connection. The VNet route map first matches each target VNet's
full address-space prefixes and replaces them with that VNet's `l2_appliance`
subnet prefixes. A following rule permits directly advertised `l2_appliance`
prefixes unchanged, and a final match-all rule drops everything else. The map is
applied to every target VNet connection plus the Gen2 AVS VNet connection when
configured. Creating the first route map upgrades the hub routing platform and
can take about 30 minutes. Azure bills route maps separately. Associations are
configured on each connection's inbound routing configuration using the full
route-map resource ID; Azure does not accept a route-map name in place of that
ID.

### Gen1

Gen1 creates an ExpressRoute gateway in the Virtual Hub and connects it to the
AVS ExpressRoute circuit private peering. Obtain the private peering resource ID
and an authorization key from the AVS private cloud.

```hcl
avs_private_cloud_connection = {
  generation = "gen1"
  name       = "erc-avs-gen1"

  gen1 = {
    expressroute_gateway_name        = "ergw-avs-gen1"
    express_route_circuit_peering_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avs/providers/Microsoft.Network/expressRouteCircuits/erc-avs/peerings/AzurePrivatePeering"
    gateway_scale_units              = 1
    fast_path_enabled                = true
  }
}
```

Pass the authorization key without committing it to a variable file:

```bash
export TF_VAR_avs_expressroute_authorization_key='<authorization-key>'
```

### Gen2

Gen2 connects the VNet associated with the AVS private cloud directly to the
Virtual Hub:

```hcl
avs_private_cloud_connection = {
  generation = "gen2"
  name       = "vhub-conn-avs-gen2"

  gen2 = {
    remote_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avs-gen2/providers/Microsoft.Network/virtualNetworks/vnet-avs-gen2"
  }
}
```

## Azure Verified Modules

- [Resource Group AVM](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/0.4.0)
- [Virtual WAN AVM submodule](https://registry.terraform.io/modules/Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm/0.17.2/submodules/virtual-wan)
- [Virtual Network AVM](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/0.22.2)
- [Virtual Machine AVM](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/0.21.0)
- [Key Vault AVM](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/0.11.0)
- [Load Balancer AVM](https://registry.terraform.io/modules/Azure/avm-res-network-loadbalancer/azurerm/0.5.0)
- [Route Table AVM](https://registry.terraform.io/modules/Azure/avm-res-network-routetable/azurerm/0.5.0)
- [Log Analytics Workspace AVM](https://registry.terraform.io/modules/Azure/avm-res-operationalinsights-workspace/azurerm/0.5.1)