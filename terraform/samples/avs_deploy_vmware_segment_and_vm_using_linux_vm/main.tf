
#create a random string for naming
resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

locals {
  #Variables for creating the new TF vm and pointing it at the target SDDC
  tf_vm_name   = "tfvm-${random_string.namestring.result}"
  tf_vm_subnet_id = "<resource subnet id for the terraform vm. This subnet needs to be able to connect to nsx and vsphere>"
  key_vault_id = "<resource id of the keyvault to store the terraform vm's password>"
  sddc_name    = "multiregion-AVS-1-SDDC-qyfw"
  sddc_rg_name = "multiregion-PrivateClouds-qyfw"
  
  #Map of values for the state storage account. In scenarios where this account existed previously, then replace these values with the existing storage account.
  vmware_state_storage = {
    resource_group_name = "vmware-test-${random_string.namestring.result}"
    account_name        = "vstate${random_string.namestring.result}"
    container_name      = "vmware-state-${random_string.namestring.result}"
    key_name            = "testkey.${random_string.namestring.result}"
  }

  #Map of values containing the credentials for authenticating to the VMware management components of the private cloud
  vmware_creds = {
    nsx = {
      ip       = split("/", data.azurerm_vmware_private_cloud.sddc.nsxt_manager_endpoint)[2]
      user     = jsondecode(data.azapi_resource_action.sddc_creds.output).nsxtUsername
      password = jsondecode(data.azapi_resource_action.sddc_creds.output).nsxtPassword
    }
    vsphere = {
      ip       = split("/", data.azurerm_vmware_private_cloud.sddc.vcsa_endpoint)[2]
      user     = jsondecode(data.azapi_resource_action.sddc_creds.output).vcenterUsername
      password = jsondecode(data.azapi_resource_action.sddc_creds.output).vcenterPassword
    }
  }


  ##########################################################################################################
  # These values control the module being deployed to the private cloud.  
  # This is where changes would be made if deploying a different TF module to the private cloud
  # This can be populated from the tfvars sample of the module if using a different module
  ##########################################################################################################
  tf_template_github_source = "github.com/Azure/Enterprise-Scale-for-AVS.git//terraform/modules/avs_vmware_composite_create_vm_and_network_segment"
  vmware_deployment = {
    nsxt_root               = upper(substr(split("/", data.azurerm_vmware_private_cloud.sddc.circuit[0].express_route_id)[8], 0, 5))
    t1_gateway_display_name = "vm_t1_gateway_2"
    dhcp_profile = {
      description      = "DHCP Profile"
      display_name     = "vm_dhcp_profile_test"
      server_addresses = "10.35.10.1/24"
    }
    vm_segment = {
      description  = "test vm segment"
      display_name = "avs1_vm_segment_2"
      subnet = {
        cidr        = "10.36.10.1/24"
        dhcp_ranges = ["10.36.10.5-10.36.10.50"]
        dhcp_v4_config = {
          server_address = "10.35.10.1/24"
          lease_time     = 86400
          dns_servers    = [cidrhost(data.azurerm_vmware_private_cloud.sddc.network_subnet_cidr, 192)]
        }
      }
      tag = {
        scope = "LevelUp"
        tag   = "NOV22-test"
      }
    }
    ovf_content_library_name = "vm_content_library_2"
    ovf_template_name        = "photon_4.0"
    ovf_template_description = "Simple photon vm template for testing"
    ovf_template_url         = "https://packages.vmware.com/photon/4.0/Rev2/ova/photon-ova-4.0-c001795b80.ova"
    vsphere_datacenter       = "SDDC-Datacenter"
    vsphere_datastore        = "vsanDatastore"
    vsphere_cluster          = "Cluster-1"
    vm_name                  = "test-photon2"
  }
}

#these data providers populate the SDDC credentials for connecting to nsx and vsphere
#get all of the SDDC details
data "azurerm_vmware_private_cloud" "sddc" {
  name                = local.sddc_name
  resource_group_name = local.sddc_rg_name
}
#get SDDC credentials for use with the VMware provider
data "azapi_resource_action" "sddc_creds" {
  type                   = "Microsoft.AVS/privateClouds@2021-12-01"
  resource_id            = data.azurerm_vmware_private_cloud.sddc.id
  action                 = "listAdminCredentials"
  response_export_values = ["*"]
}

##########################################################################################################
# These resources create the storage account used for the terraform state file for the VMWare deployment
##########################################################################################################
#create a resource group for the vmware state resource group
resource "azurerm_resource_group" "vmware_test" {
  name     = local.vmware_state_storage.resource_group_name
  location = "Canada Central"
}

#create a storage account for vmware state files
resource "azurerm_storage_account" "vmware_state" {
  name                     = local.vmware_state_storage.account_name
  resource_group_name      = azurerm_resource_group.vmware_test.name
  location                 = azurerm_resource_group.vmware_test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "vmware_state_container" {
  name                  = local.vmware_state_storage.container_name
  storage_account_name  = azurerm_storage_account.vmware_state.name
  container_access_type = "private"
}

##########################################################################################################################
# This is the module that creates a linux VM and runs the terraform init/apply to deploy the vmware components
# Ideally, this configuration would only require modifying the target module and deployment values to deploy other modules
##########################################################################################################################
module "deploy_tf_vm" {
  source = "../../modules/avs_deploy_vmware_modules_with_tf_vm"

  rg_name                   = azurerm_resource_group.vmware_test.name
  rg_location               = azurerm_resource_group.vmware_test.location
  tf_vm_subnet_id           = local.tf_vm_subnet_id
  tf_vm_name                = local.tf_vm_name
  key_vault_id              = local.key_vault_id
  vmware_creds              = local.vmware_creds
  vmware_state_storage      = local.vmware_state_storage
  vmware_deployment         = local.vmware_deployment
  tf_template_github_source = local.tf_template_github_source
  sddc_name                 = local.sddc_name
  sddc_rg_name              = local.sddc_rg_name

  depends_on = [
    azurerm_storage_container.vmware_state_container
  ]
}
