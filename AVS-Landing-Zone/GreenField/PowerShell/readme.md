# Deployment Steps (AZ PowerShell)

1. Clone this repository onto either the Azure Cloud Shell or local machine
2. Modify the `deploys.ps1` files in each section to define desired parameters, networking, and alert emails

This section is broken down into folders and sections so that you can deploy each piece as needed

1. [Resource Groups](1.resource_group_design)
2. [Azure VMware Private Cloud](2.private_cloud)
3. [Networking](3.network-design)
4. [Jump box](4.jumpbox-design)
5. [Reporting](05.reporting)
6. [Addons](06.add-ons)

Each section is designed to be run as a module with a dependency on the previous module. As a result, variables are several times allowing you close the browser or terminal and find your place again. Each folder has a ***"deploy.ps1"*** file which is the file used to deploy the required code.

[Folder 2 (2.priavte_cloud)](/AVS-Landing-Zone/GreenField/PowerShell/2.private_cloud/) also has a [deployment check.ps1](2.private_cloud/deploymentcheck.ps1) file to help you keep an eye on this deployment as this takes some time.

If you know where your Subscription ID and Tenant ID, you can use [this script](login.ps1)
If you have multiple subscription(s) or do not know all your IDs, you can use [this script](list_and_connect_to_subscription.ps1)

## File Variables for advanced options

Most, if not all optional elements will have a variable like *$deploy*Technology, for example *$deployVpn*. These are set of **$false** by default and this is by design for cost optimization and deploying only what is actually needed. Please look for these and change as needed.  

## Telemetry Tracking Using Customer Usage Attribution (PID)

Microsoft can identify the deployments of the Azure Resource Manager and Bicep templates with the deployed Azure resources. Microsoft can correlate these resources used to support the deployments. Microsoft collects this information to provide the best experiences with their products and to operate their business. The telemetry is collected through [customer usage attribution](https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution). The data is collected and governed by Microsoft's privacy policies, located at the [trust center](https://www.microsoft.com/trustcenter).

To disable this tracking, we have included a variable called $telemetry to every bicep module in this repo with a simple boolean flag. The default value *true* which does not disable the telemetry. If you would like to disable this tracking, then simply set this value to false and this module will not be included in deployments and therefore disables the telemetry tracking.  

If you are happy with leaving telemetry tracking enabled, no changes are required. Please do not edit the module name or value of the variable $telemetry in any file.

For example, in each deploy.ps1 file, you will see the following:

```powershell
if ($telemetry) {
  ## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers
    Write-Output "Telemetry enabled"
    $telemetryId = "pid-e3bf694a-443e-475c-a0ef-ab3bc9990338"
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($telemetryId)
} else {
    Write-Host "Telemetry disabled"
}
```  

The default value is true, but by changing the parameter value false and saving this file, when you deploy this module either via PowerShell, Azure CLI, or as part of a pipeline the module deployment below will be ignored and therefore telemetry will not be tracked.

## Module PID Value Mapping

|Folder  |File  |PID  |
|---------|---------|---------|
|resource-group     | deploy.ps1 | pid-4c6f5558-ec2a-449b-9e68-7530d7ee8b1e        |
|private-cloud     | deploy.ps1 | pid-9e4a4112-75bc-47ed-afb6-960ab433dcea        |
|network-design     | deploy.ps1  | pid-b3e5a0bb-b96b-4250-84a1-39eca087d10f        |
|jumpbox-design    | deploy.ps1 | pid-e3bf694a-443e-475c-a0ef-ab3bc9990338   |
|reporting    | deploy.ps1 | pid-1b3bba10-820a-4081-9c50-a3b9861be3f9    |
