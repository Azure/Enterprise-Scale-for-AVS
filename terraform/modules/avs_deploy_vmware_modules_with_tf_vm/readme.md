# Deploy a VMware Terraform Module to a private cloud as part of a larger Azure Terraform implementation

## Sample Details

This module allows for the deployment of VMware Terraform modules as part of a larger Azure Terraform deployment.  The intent with this module is to enable large lab or customer implementations that include both Azure components as well as VMWare components in one larger parent module.  

This module accomplishes with by deploying an Ubuntu 18.04 linux virtual machine into an existing subnet on Azure that has connectivity to the private cloud management appliances. This configuration then leverages cloud-init and Terraform's template-file provider to create a main.tf file that has been populated with the connection and module variable values. This is done by converting the map objects into JSON strings and then converting them back to a map object when the module is applied to get around Terraform's requirement that each template file interpolation be a single string. Cloud-init then downloads and installs the latest Terraform application, changes directory into the /tmp/terraform directory with the main.tf file, and executes `terraform init` and `terraform apply -auto-approve` to install the modules.

Because VMware NSX-T and VSphere allow for the creation of identically configured objects, this module requires that an Azure Storage Account be used for remote state. This allows for the re-deployment of the virtual machine without running into issues where VMware deployments fail because multiple versions of the same object exist within Vsphere or NSX-T. It is still possible to deploy the same object twice if different backend state configurations are used or different modules create an identically configured object so use caution when building modules.

This module is intended to be re-usable as long as the module being called consolidates its variables into two maps and duplicates the providers file configuration:
- vmware_deployment holds the values being passed to the called VMware Terraform module.  See the [sample](../../samples/avs_deploy_vmware_segment_and_vm_using_linux_vm/readme.md) in our samples directory for an example of how this would look.
- vmware_state_storage holds the configuration details for the storage account used for remote state. This isn't required for this module to function, but is included in the event that your module might need to read the state file or need access to the state file storage account.

## Troubleshooting

When developing new VMWare modules or troubleshooting existing VMware modules, there are a few different common things to consider. 
- The main.tf that is generated is stored at /tmp/terraform on the deployed linux VM. Running terraform init and plan/apply will work as it would if you were deploying directly. Running terraform as root is currently required as cloud-init runs as root. (We may update this in a future release to change the permissions and ownership of these files if we get feedback that this is desired) Running the code locally on the VM is useful for troubleshooting syntax or reference errors in your VMware Terraform code.  Be sure to push any code changes to the repo branch being deployed when correcting errors and run terraform -init upgrade to pull the latest version of the code after you push changes to your repo if you choose not to redeploy the vm. 
- For the deployment to work, the deployment VM is required to have access to the AVS private cloud NSXT manager and Vsphere host. You can test this by using Curl to test connectivity to the web interfaces. 
- The template-file provider for vmware stores the template as a sensitive value.  Because of this, each time you re-run a `terraform apply` for this calling module it will destroy and recreate the virtual machine. The state file handles this in most cases as the subsequent apply of the VMware specific module will not have any changes. 


