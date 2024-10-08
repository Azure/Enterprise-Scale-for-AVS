# Deploy IPSec VPN in AVS NSX-T

This guidance covers the automation script that can be used in setting up IPSec VPN in AVS NSX-T.

## Prerequisites

* Azure subscription to be used for private cloud depployment or already running private cloud.
    * `$tenantId` = `<Provide your Azure tenant ID>`
    * `$subscriptionId` = `<Provide the Azure subscription ID which has AVS SDDC deployed in it>`
    * `$AVSSDDCresourceGroupName` = `"<Provide the Azure resource group name in which AVS SDDC is deployed">`
        $privateCloudName = "AVsforArc"
        $publicIpName = "AVS-VPN-Public-IP"
        $numberOfPublicIPs = 1
        $tier1GatewayName = "maksh-T1-gateway-vpn"
        $dnsServiceName = "maksh-dns-service-vpn"
        $dhcpProfileName = "maksh-DHCP-2"
        $segmentName = "maksh-vpn-segment"
        $ipSecVpnServiceName = "maksh-ipsec-vpn"
        $ipSecVpnLocalEndpointName = "maksh-ipsec-vpn-lep"
        $ipSecVpnSessionName = "maksh-ipsec-vpn-session"
        $remoteGatewayIP = "4.174.250.100"
        $remoteNetwork = "192.168.0.32/29"
* Clone of this regpository with `Scripts` folder

## Deployment Steps

* Update the parameter values in `AVSIPSecVPN.ps1` as discussed below.


* Run following script.

### CLI

```bash
az account set -s <YOUR-SUBSCRIPTION-ID>

cd CLI

./log2phy.sh

# to run the script for a specific subscription, use following commands
./log2phy.sh [subscription-id]
```

### Azure Cloud Shell

* Login to shell.azure.com. Start a bash shell.

* Copy the contents from log2phy.sh file and paste it into shell window. Hit enter.

* Script starts to run for each region.

* When finished, Logical to physical zone mapping is returned for each location associated with subscription as shown in the image below.

    ![Logical to physical mapping for zones in Azure](log2phyimg.png)

## Post-deployment Steps

* Use the logical to physical zone mapping information for deployment of other Azure services in same availability zone as Azure VMware Solution private cloud as appropriate.

## Next Steps

[Configure Workbook](../AVS-Workbook/readme.md)
