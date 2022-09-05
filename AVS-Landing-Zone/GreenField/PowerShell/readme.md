# Deployment Steps (AZ PowerShell)

1. Clone this repository onto either the Azure Cloud Shell or local machine
2. Modify the `deploys.ps1` files in each section to define desired parameters, networking, and alert emails

This section is broken down into folders and sections so that you can deploy each piece as needed

1. [Resource Groups](1.resource_group_design)
2. [Azure VMware Private](2.private_cloud)
3. [Networking](3.network-design)
4. [Jumpbox](4.jumpbox-design)
5. [Reporting](05.reporting)
6. [Addons](06.add-ons)

Each section is designed to be run as a module with a dependency on the previous module. As a result, variables are several times allowing you close the browser or terminal and find your place again. Each folder has a ***"deploy.ps1"*** file which is the file used to deploy the required code.

[Folder 2 (2.priavte_cloud)](/AVS-Landing-Zone/GreenField/PowerShell/2.private_cloud/) also has a [deployment check.ps1](2.private_cloud/deploymentcheck.ps1) file to help you keep an eye on this deployment as this takes some time.

If you know where your Subscription ID and Tenant ID, you can use [this script](login.ps1)
If you have multiple subscription(s) or do not know all your IDs, you can use [this script](list_and_connect_to_subscription.ps1)
