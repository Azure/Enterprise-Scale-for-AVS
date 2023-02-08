# Deployment Steps (Azure PowerShell)

This code can be deployed in 2 different manners. You can use each folder to deploy each component [individually](#individual-deployment) or you can use a [master](#master-script) `deploys.ps1` to deploy all aspects in one session.

1. Clone this repository onto either the Azure Cloud Shell or local machine  ```git clone git clone <repository-url>```
2. Update the [variables file](variables/variables.json) to meet you need.
3. Choose your deployment method, please pick one or the other.
   1. [Individual component deployment](#individual-deployment) _**OR**_
   2. [Master Script deployment](#master-script)

## Recommendations

1. Make sure your Azure PowerShell is up to date. You can check this by running the following command in PowerShell. ```Update-Module -Name Az```
2. Due to the length of the overall deployment, it is recommended that you use a local PowerShell session and not Cloud Shell due to potential timeout issues.

## Individual Deployment

Each folder [Resource Groups](1.resource-group), [Azure VMware Private Cloud](2.private-cloud), [Networking](3.network), [Jump box](4.jumpbox), [Reporting](05.reporting), [Addons](06.add-ons) represents a different component that can be deployed. To deploy a component, navigate to the required folder and run the ``deploy.ps1`` file.

Each section is designed to be run as a module with a dependency on the previous module. As a result, variables are several times allowing you close the browser or terminal and find your place again. Each folder has a **``deploy.ps1``** file which is the file used to deploy the required code.

1. [Resource Group deployment](1.resource-group/deploy-withjson.ps1)
2. [Private Cloud deployment](2.private-cloud/deploy-withjson.ps1)
3. [Networking deployment](3.network/deploy-withjson.ps1)
4. [Jump box deployment](4.jumpbox/deploy-withjson.ps1)

The [Private Cloud deployment](2.private-cloud/deploy-withjson.ps1) takes some time to complete. A [deployment check.ps1](2.private-cloud/deploymentcheck.ps1) has been included to help you monitor this, the average deployment time for a 3/4 node environment takes between 3 and 4 hours.

## Master Script

### How to get subscription IDs

If you know where your Subscription ID and Tenant ID, you can use this [script](login.ps1)
If you have multiple subscription(s) or do not know all your IDs, you can use [this script](list_and_connect_to_subscription.ps1)

Once you have logged in and are now in the correct Azure Context, use this [script](deploy.ps1) to deploy all aspects.

## Telemetry Tracking Using Customer Usage Attribution (PID)

Microsoft can identify the deployments of the Azure Resource Manager and Bicep templates with the deployed Azure resources. Microsoft can correlate these resources used to support the deployments. Microsoft collects this information to provide the best experiences with their products and to operate their business. The telemetry is collected through [customer usage attribution](https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution). The data is collected and governed by Microsoft's privacy policies, located at the [trust center](https://www.microsoft.com/trustcenter).

To disable this tracking, we have included a variable called $telemetry to every bicep module in this repo with a simple boolean flag. The default value _true_ which does not disable the telemetry. If you would like to disable this tracking, then simply set this value to false and this module will not be included in deployments and therefore disables the telemetry tracking.  

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
|resource-group     | [deploy-withjson.ps1](1.resource-group/deploy-withjson.ps1)  | pid-4c6f5558-ec2a-449b-9e68-7530d7ee8b1e        |
|private-cloud     | [deploy-withjson.ps1](2.private-cloud/deploy-withjson.ps1)  | pid-9e4a4112-75bc-47ed-afb6-960ab433dcea        |
|network     | [deploy-withjson.ps1](3.network/deploy-withjson.ps1)  | pid-b3e5a0bb-b96b-4250-84a1-39eca087d10f        |
|jumpbox    | [deploy-withjson.ps1](4.jumpbox/deploy-withjson.ps1)  | pid-e3bf694a-443e-475c-a0ef-ab3bc9990338   |
|reporting    | deploy-withjson.ps1 | pid-1b3bba10-820a-4081-9c50-a3b9861be3f9    |
