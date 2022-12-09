# AVS Landing Zone: Brownfield Deployment

This section contains templates to deploy specific components and add-ins for AVS. These templates can be used individually as required.

## AVS Portal UI Accelerators (All-in-one Portal Experience)
| Deploy                     | Description                                                  | Deploy                                                       |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| AVS Monitoring and Logging | This is an all in one portal experience to deploy AVS Monitoring components and enable logging for your Private Cloud | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FMonitoring%2FAVS-Monitoring-PortalUI%2FARM%2FESLZDeploy.deploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FMonitoring%2FAVS-Monitoring-PortalUI%2FARM%2FESLZdeploy.Monitoring.PortalUI.json) |

## AVS Private Cloud + Add-ons

| Deploy                                    | Description                                                  | Deploy                                                       | More Info                                                    |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Single AVS Private Cloud                  | This example will deploy a single private cloud within selected resource group | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FPrivateCloud%2FAVS-PrivateCloud%2FARM%2FPrivateCloud.deploy.json) | [Link](PrivateCloud/AVS-PrivateCloud/readme.md) |
| Single AVS Private Cloud with HCX enabled | This example will deploy a single private cloud within selected resource group with HCX enabled | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FPrivateCloud%2FAVS-PrivateCloud-WithHCX%2FARM%2FPrivateCloudWithHCX.deploy.json) | [Link](PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md)
| Enable SRM for AVS Private Cloud     | This example will enable the VMware Site Recovery Manger add-on to an existing AVS Private Cloud | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FAddons%2FSRM%2FARM%2FSRM.deploy.json) | [Link](Addons/SRM//readme.md) |
| Enable HCX for AVS Private Cloud     | This example will enable the VMware HCX add-on to an existing AVS Private Cloud | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FAddons%2FHCX%2FARM%2FHCX.deploy.json) | [Link](Addons/HCX/readme.md) |

###### *Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*

## AVS Storage

| Deploy                                    | Description                                                  | Deploy                                                       | More Info                                                    |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ANF datastore                     | This example will create an [Azure NetApp Files datastore](https://learn.microsoft.com/azure/azure-vmware/attach-azure-netapp-files-to-azure-vmware-solution-hosts), dedicated virtual network, and virtual network gateway | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FStorage%2FAVS-to-ANFdatastore-NewVNet%2FARM%2FANFdatastoreWithNewVNet.deploy.json) | [Link](Storage/AVS-to-ANFdatastore-NewVNet/readme.md) |


###### *Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*


## AVS Monitoring (Resource Group Scope)
The examples below are all scoped at the resource group level. These will be useful in cases where you have not been given subscription rights and can therefore only perform actions at a resource group level

| Deploy                                    | Description                                                  | Deploy                                                       | More Info                                                    |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Enable AVS Monitoring                     | This example will create an action group and example metric alerts for monitoring AVS Private Cloud | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FMonitoring%2FAVS-Utilization-Alerts%2FARM%2FAVSMonitor.deploy.json) | [Link](Monitoring/AVS-Utilization-Alerts/readme.md) |
| Service Health Alerts              | This example will create an action group & set up Service Health alerting for AVS in a specified region | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FMonitoring%2FAVS-Service-Health%2FARM%2FAVSServiceHealth.deploy.json) | [Link](Monitoring/AVS-Service-Health/readme.md) |
| AVS Dashboard                     | This example will create an Azure Dashboard showing the Private Cloud metrics, and optionally ExpressRoute connection metrics | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FMonitoring%2FAVS-Dashboard%2FARM%2FAVSDashboard.deploy.json) | [Link](Monitoring/AVS-Dashboard/readme.md) |
| AVS Workbook                     | This example is an Azure Monitor workbook highlighting information about the Private Clouds, including overview, performance, VMs, alerts and activity. | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FMonitoring%2FAVS-Workbook%2FARM%2FAVSWorkbook.deploy.json) | [Link](Monitoring/AVS-Workbook/readme.md) |

###### *Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*

## AVS Networking

| Deploy                                                       | Description                                                  | Deploy                                                       | More Info                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Connect AVS to a new virtual network                         | This example will create a new virtual network, new gateway in desired resource group and will connect this new network to AVS Private Cloud |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-VNet-NewVNet%2FARM%2FVNetWithExR.deploy.json) | [Link](Networking/AVS-to-VNet-NewVNet/readme.md) |
| Connect AVS to an existing virtual network (Generate Authorization Key) | This example will connect an existing virtual network and gateway with AVS Private Cloud. An authorization key will be generated from the AVS Private Cloud circuit automatically | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-VNet-ExistingVNet%2FARM%2FExRConnection.deploy.json) | [Link](Networking/AVS-to-VNet-ExistingVNet/readme.md) |
| Connect AVS to an existing virtual network (Separate Authorization Key) | This example will connect an existing virtual network and gateway with AVS Private Cloud. An authorization key needs to be specified as part of the deployment | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FExpressRoute-to-VNet%2FARM%2FExRConnection.deploy.json) | [Link](Networking/ExpressRoute-to-VNet/readme.md) |
| Connect AVS to On-premises ExpressRoute Circuit via Global Reach | This example will connect AVS Private Cloud to on-premises ExpressRoute Gateway | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-OnPremises-ExpressRoute-GlobalReach%2FARM%2FAVSGlobalReach.deploy.json) | [Link](Networking/AVS-to-OnPremises-ExpressRoute-GlobalReach/readme.md) |
| Connect AVS to AVS in a different region via Global Reach    | This example will connect 2 AVS Private Clouds in 2 different regions using ExpressRoute Global Reach | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-AVS-CrossRegion-GlobalReach%2FARM%2FCrossAVSGlobalReach.deploy.json) | [Link](Networking/AVS-to-AVS-CrossRegion-GlobalReach/readme.md) |
| Connect AVS to AVS in the same region via AVS Interconnect   | This example will connect 2 AVS Private Clouds in same region using the AVS Interconnect feature | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-AVS-SameRegion%2FARM%2FCrossAVSWithinRegion.deploy.json) | [Link](Networking/AVS-to-AVS-SameRegion/readme.md) |

###### *Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*

## AVS Networking Step-by-Step Guides

| Scenario                                                 | Description                                                          | More Info |
| -------------------------------------------------------- | -------------------------------------------------------------------- | --------- |
| Expressroute connectivity for AVS without Global Reach                                               | Connect an AVS Private Cloud to an on-prem network over ExpressRoute, leveraging an existing firewalling solution in Azure (without Global Reach)       | [Link](Networking/Step-By-Step-Guides/Expressroute%20connectivity%20for%20AVS%20without%20Global%20Reach/readme.md) |
| Implementing internet connectivity for AVS with Azure NVAs | Internet outbound access for AVS via Azure NVAs running in an Azure VNet | [Link](Networking/Step-By-Step-Guides/Implementing%20internet%20connectivity%20for%20AVS%20with%20Azure%20NVAs) |



