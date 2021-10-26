### Scenarios

Here are the scenarios available today. For more information, browse to the respective scenario

| Deploy                              | Description                                                  | Deploy                                                       | More Info                               |
| ----------------------------------- | :----------------------------------------------------------- | ------------------------------------------------------------ | --------------------------------------- |
| AVS Landing Zone in a Single Region | This deployment is an end to end AVS landing zone deployment in a selected subscription and region, with a jumpbox in a new VNet for connectivity as well as monitoring, as per enterprise scale architecture | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./AVS-Landing-Zone/SingleRegion) |

*Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*



<br/>

#### AVS Component Deployment Examples

In the event you would like to deploy single features or components of the AVS Enterprise Scale deployment, please see the various options below:

##### AVS Private Cloud + Add-ins

| Deploy                                    | Description                                                  | Deploy                                                       | More Info                                                |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------------------- |
| Single AVS Private Cloud                  | This example will help deploy a single private cloud within selected resource group | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/PrivateCloud/AVS-PrivateCloud)         |
| Single AVS Private Cloud with HCX enabled | This example will help deploy a single private cloud within selected resource group with HCX enabled | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/PrivateCloud/AVS-PrivateCloud-WithHCX) |
| Enable SRM for AVS Private Cloud     | This example will enable the VMware Site Recovery Manger add-on to an existing AVS Private Cloud | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Addins/SRM)                            |
| Enable HCX for AVS Private Cloud     | This example will enable the VMware HCX add-on to an existing AVS Private Cloud | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Addins/HCX)                            |
| Enable AVS Monitoring                     | This example will create an action group and example metric alerts for monitoring AVS Private Cloud | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Monitoring/AVS-Utilization-Alerts)     |

*Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*

<br/>

##### AVS Networking

| Deploy                                                       | Description                                                  | Deploy                                                       | More Info                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Connect AVS to a new virtual network                         | This example will create a new virtual network, new gateway in resource group and will connect this new network to AVS Private Cloud | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Networking/AVS-to-VNet-NewVNet)            |
| Connect AVS to an existing virtual network (Generate Authorization Key) | This example will connect an existing virtual network and gateway with AVS Private Cloud. An authorization key will be generated from the AVS Private Cloud circuit automatically | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Networking/AVS-to-VNet-ExistingVNet)       |
| Connect AVS to an existing virtual network (Specify Authorization Key) | This example will connect an existing virtual network and gateway with AVS Private Cloud. An authorization key needs to be specificed as part of the deployment | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Networking/ExpressRoute-to-VNet)           |
| Connect AVS to On-premises ExpressRoute Circuit via Global Reach | This example will connect AVS Private Cloud to on-premises ExpressRoute Gateway | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Networking/AVS-to-OnPremises-ExpressRoute-GlobalReach) |
| Connect AVS to AVS in a different region via Global Reach    | This example will connect 2 AVS Private Clouds in 2 different regions using ExpressRoute Global Reach | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Networking/AVS-to-AVS-CrossRegion-GlobalReach) |
| Connect AVS to AVS in the same region via AVS Interconnect   | This example will connect 2 AVS Private Clouds in same region using the AVS Interconnect feature | ![](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg) | [Link](./Examples/Networking/AVS-to-AVS-SameRegion)          |

*Note: Navigate to the more info link to view detailed information and other IaC languages such as Bicep*

<br/>