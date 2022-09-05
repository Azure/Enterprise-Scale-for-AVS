# Deployment Steps (AZ PowerShell)

1. Clone this repository onto either the Azure Cloud Shell or local machine
2. Modify the `deploys.ps1` files in each section to define desired parameters, networking, and alert emails

This section is broken down into folders and sections so that you can deploy each piece as needed

1. [Resource Groups](1.resource_group_design)
2. [Azure VMware Private Cloud](2.private_cloud)
3. [Networking](3.network-design)
4. [Jumpbox](4.jumpbox-design)
5. [Reporting](05.reporting)
6. [Addons](06.add-ons)

If you know where your Subscription ID and Tenant ID, you can use [this script](login.ps1)
If you have multiple subscription(s) or do not know all your IDs, you can use [this script](list_and_connect_to_subscription.ps1)

## File Variables for advanced options

Most, if not all optional elements will have a variable like *$deploy*Technology, for example *$deployVpn*. These are set of **$false** by default and this is by design for cost optimization and deploying only what is actually needed. Please look for these and change as needed.  