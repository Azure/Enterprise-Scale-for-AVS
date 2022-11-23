# Deploy a Photon test VM to a new DHCP enabled T1 and network segment

## Table of contents

- [Sample Details](#sample-details)
- [Sample Implementation - Automation Options](#automation-implementation)
- [Appendix](#appendix)


## Sample Details

This sample demonstrates the configuration and use of a module that deploys Azure VMware Solution Terraform code as part of a larger Azure Terraform implementation. This is accomplished by leveraging an Azure VM to run the VMware specific Terraform modules.  Specific technical details about how the key module works can be found in the [readme](../../modules/avs_deploy_vmware_modules_with_tf_vm/readme.md) for the avs_deploy_vmware_modules_with_tf_vm module.


[(Back to top)](#table-of-contents)

## Automation implementation

This sample is a root module that calls a number of child modules included in the modules and scenarios subdirectories of the terraform directory.  This root module inputs the deployed values directly in the submodule calls, so to change the deployment behavior, modify the values directly in the main.tf file. This module also includes a sample providers file that can be modified to fit your specific environment.

To deploy this module, ensure you have a deployment machine that meets the pre-requisites for Azure Deployments with terraform. Clone this repo to a local directory on the deployment machine.  Update the main.tf variable values and make any updates to the providers sample file backend block and uncomment them if needed.

Execute the terraform init/plan/apply workflow to execute the deployment.

[(Back to top)](#table-of-contents)

## Appendix


[(Back to top)](#table-of-contents)