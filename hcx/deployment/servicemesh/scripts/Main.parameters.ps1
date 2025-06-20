# This file contains the parameters required for deploying the HCX Service Mesh in Azure VMware Solution (AVS).

# $tenantID paramemter is used to specify the Azure Active Directory tenant ID.
# Example: "27eda5xx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# This tenant ID is used to authenticate and authorize access to Azure resources.
$tenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# $subscriptionID parameter is used to specify the Azure subscription ID.
# Example: "d52f9xxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx"
# This subscription ID is used to identify the Azure subscription where the AVS SDDC is
# deployed and where the HCX Service Mesh will be created.
# Ensure that you have the necessary permissions to create resources in this subscription.
$subscriptionId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# $avsSddcName parameter is used to specify the name of the Azure VMware Solution SDDC.
# Example: "maksh1-SDDC"
# AVS SDDC must have HCX Add-on enabled.
# HCX Connector must be deployed in the on-premises environment.
# If not already done, please refer to the HCX documentation for deploying the HCX Connector in your on-premises environment.
# https://github.com/Azure/Enterprise-Scale-for-AVS/blob/main/hcx/deployment/connector/README.md
$avsSddcName = "xxxxxx-SDDC"
# $hcxConnectorUserName parameter is used to specify the username for the HCX Connector.
# Example: "administrator@avs.lab"
# This user must have administrative privileges on the HCX Connector.
# It's password will be prompted for when script is executed.
$hcxConnectorUserName = "administrator@xxx.xxx"
# $hcxConnectorServiceUrl parameter is used to specify the service URL of the HCX Connector.
# Example: "https://10.1.1.9/" or "https://hcx-connector.avs.lab/"
# This URL is used to connect to the HCX Connector service.
# It should be the URL of the HCX Connector deployed in your on-premises environment.
# It can be either an IP address or a fully qualified domain name (FQDN).
$hcxConnectorServiceUrl = "https://X.X.X.X/"
# $hcxConnectorMgmtUrl parameter is used to specify the management URL of the HCX Connector.
# Example: "https://10.1.1.9:9443/" or "https://hcx-connector.avs.lab:9443/"
# This URL is used to administer/manage the HCX Connector service.
# It can be either an IP address or a fully qualified domain name (FQDN).
# It has :9443 port number by default.
# If you have changed the port number during HCX Connector deployment, please update this parameter accordingly
$hcxConnectorMgmtUrl = "https://X.X.X.X:9443/"
# *****The following parameters are used to specify the network profiles for the HCX Service Mesh.****
# ***************************************************************************************** 
# *****************************************************************************************
# Management Network Profile
# ****************************************************************************************
# $managementNetworkName parameter is used to specify the name of the on-premises management network.
# Example: "OnPrem-management-1-1"
# This network should pre-exist in the on-premises environment.
$managementNetworkName = "OnPrem-management-X-X"
# $managementNetworkStartIPAddress parameter is used to specify the starting IP address of the management network.
# Example: "10.1.1.10"
# This IP address should be within the range of the management network.
$managementNetworkStartIPAddress = "X.X.X.XX"
# $managementNetworkEndIPAddress parameter is used to specify the ending IP address of the management network.
# Example: "10.1.1.16"
# This IP address should be within the range of the management network.
$managementNetworkEndIPAddress = "X.X.X.XX"
# $managementNetworkGatewayIPAddress parameter is used to specify the gateway IP address of the management network.
# Example: "10.1.1.1"
# This IP address should be the gateway for the management network.
$managementNetworkGatewayIPAddress = "X.X.X.X"
# $managementNetworkPrefixLength parameter is used to specify the prefix length of the management network.
# Example: 27
# This is typically the subnet mask length, e.g., 24 for a /24 subnet
$managementNetworkPrefixLength = XX
# $managementNetworkDNSIPAddress parameter is used to specify the DNS IP address for the management network.
# Example: "1.1.1.1"
# Ensure that this DNS server is reachable from the management network.
$managementNetworkDNSIPAddress = "X.X.X.X"
# *****************************************************************************************
# Uplink Network Profile
# *****************************************************************************************
# $uplinkNetworkName parameter is used to specify the name of the on-premises uplink network.
# Example: "OnPrem-uplink-1-1"
# This network should pre-exist in the on-premises environment.
# In some cases, Management network is also used as uplink network.
# In such cases, refer to another parameters $useMgmtForUplinkInComputeProfile and $useMgmtForUplinkInServiceMesh
$uplinkNetworkName = "OnPrem-uplink-X-X"
# $uplinkNetworkStartIPAddress parameter is used to specify the starting IP address of the uplink network.
# Example: "10.1.1.34"
# This IP address should be within the range of the uplink network.
$uplinkNetworkStartIPAddress = "X.X.X.XX"
# $uplinkNetworkEndIPAddress parameter is used to specify the ending IP address of the uplink network.
# Example: "10.1.1.40"
# This IP address should be within the range of the uplink network.
$uplinkNetworkEndIPAddress = "X.X.X.XX"
# $uplinkNetworkGatewayIPAddress parameter is used to specify the gateway IP address of the uplink network.
# Example: "10.1.1.33"
$uplinkNetworkGatewayIPAddress = "X.X.X.XX"
# $uplinkNetworkPrefixLength parameter is used to specify the prefix length of the uplink network.
# Example: 28
$uplinkNetworkPrefixLength = XX
# $uplinkNetworkDNSIPAddress parameter is used to specify the DNS IP address for the uplink network.
# Example: "1.1.1.1"
# Ensure that this DNS server is reachable from the uplink network.
$uplinkNetworkDNSIPAddress = "X.X.X.X"
# *****************************************************************************************
# vMotion Network Profile
# *****************************************************************************************
# $vmotionNetworkName parameter is used to specify the name of the on-premises vMotion network.
# Example: "OnPrem-vmotion-1-1"
$vmotionNetworkName = "OnPrem-vmotion-X-X"
# $vmotionNetworkStartIPAddress parameter is used to specify the starting IP address of the vMotion network.
# Example: "10.1.1.74"
$vmotionNetworkStartIPAddress = "X.X.X.XX"
# $vmotionNetworkEndIPAddress parameter is used to specify the ending IP address of the vMotion network.
# Example: "10.1.1.77"
$vmotionNetworkEndIPAddress = "X.X.X.XX"
# $vmotionNetworkGatewayIPAddress parameter is used to specify the gateway IP address of the vMotion network.
# Example: "10.1.1.65"
$vmotionNetworkGatewayIPAddress = "X.X.X.XX"
# $vmotionNetworkPrefixLength parameter is used to specify the prefix length of the vMotion network.
# Example: 27
$vmotionNetworkPrefixLength = XX
# $vmotionNetworkDNSIPAddress parameter is used to specify the DNS IP address for the vMotion network.
# Example: "1.1.1.1"
$vmotionNetworkDNSIPAddress = "X.X.X.X"
# *****************************************************************************************
# Replication Network Profile
# *****************************************************************************************
# $replicationNetworkName parameter is used to specify the name of the on-premises replication network.
# Example: "OnPrem-replication-1-1"
$replicationNetworkName = "OnPrem-replication-X-X"
# $replicationNetworkStartIPAddress parameter is used to specify the starting IP address of the replication network.
# Example: "10.1.1.106"
$replicationNetworkStartIPAddress = "X.X.X.XXX"
# $replicationNetworkEndIPAddress parameter is used to specify the ending IP address of the replication network.
# Example: "10.1.1.109"
$replicationNetworkEndIPAddress = "X.X.X.XXX"
# $replicationNetworkGatewayIPAddress parameter is used to specify the gateway IP address of the replication network.
# Example: "10.1.1.97"
$replicationNetworkGatewayIPAddress = "X.X.X.XX"
# $replicationNetworkPrefixLength parameter is used to specify the prefix length of the replication network.
# Example: 27
$replicationNetworkPrefixLength = XX
# $replicationNetworkDNSIPAddress parameter is used to specify the DNS IP address for the replication network.
# Example: "1.1.1.1"
$replicationNetworkDNSIPAddress = "X.X.X.X"
# *****************************************************************************************
# *****Network Profiles for HCX Service Mesh - End*****
# *****************************************************************************************
# $computeProfileName parameter is used to specify the name of the compute profile.
# Example: "AVS-Migration-Compute-Profile"
$computeProfileName = "XXX-Migration-Compute-Profile"
# $useMgmtForUplinkInComputeProfile parameter is used to specify whether to use the management network as the uplink network in the compute profile.
# Example: $true
# If set to $true, the management network will be used as the uplink network in the compute profile.
# If set to $false, the uplink network will be used as the uplink network in the compute profile.
# This is useful when the management network is also used as the uplink network in the on-premises environment.
$useMgmtForUplinkInComputeProfile = $false
# $serviceMeshName parameter is used to specify the name of the HCX Service Mesh.
# Example: "AVS-Migration-Service-Mesh"
$serviceMeshName = "XXX-Migration-Service-Mesh"
# $useMgmtForUplinkInServiceMesh parameter is used to specify whether to use the management network as the uplink network in the HCX Service Mesh.
# Example: $true
# If set to $true, the management network will be used as the uplink network in the HCX Service Mesh.
# If set to $false, the uplink network will be used as the uplink network in the HCX Service Mesh.
# This is useful when the management network is also used as the uplink network in the on
$useMgmtForUplinkInServiceMesh = $false