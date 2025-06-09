# Main.parameters.ps1
# Simplified parameters file

# String parameters
# $vCenter parameter represents the vCenter server URL.
# It is where the HCX Connector will be deployed.
# This site generally represents on-premises vCenter server.
# It can be FQDN or IP address. Remember to include trailing slash.
# Example: "https://vcenter.example.com/" or "https://10.1.1.2/"
$vCenter = "https://10.1.1.2/"

# $vCenterUserName parameter represents the vCenter username.
# It is used to authenticate against the vCenter server.
# It's password will be prompted for during execution.
# Same password will be used for HCX configuration. 
# Example: "administrator@vsphere.local"
$vCenterUserName = "administrator@avs.lab"

# $datastoreName parameter represents the name of the datastore.
# It is where the HCX Connector OVA will be stored using content library.
# Example: "LabDatastore"
$datastoreName = "LabDatastore"

# $contentLibraryName parameter represents the name of the content library.
# It is used to store the HCX Connector OVA file.
# If the content library does not exist, it will be created.
# It it already exists, it will be used.
# Example: "vsphere-content-library"
$contentLibraryName = "vsphere-content-library"

# $contentLibraryitemName parameter represents the name of the content library item.
# It is used to store the HCX Connector OVA file.
# If the content library item does not exist, it will be created.
# If it already exists, it will be used.
# Example: "HCX-Connector"
# Note: This name should be unique within the content library.
$contentLibraryitemName = "HCX-Connector"

# $applianceFilePath parameter represents the path to the HCX Connector OVA file.
# It is used to upload the OVA file to the content library item.
# Make sure the OVA file is accessible from the machine where the script is executed.
# Example: "C:\Users\jumpboxadmin\Downloads\VMware-HCX-Connector-4.11.0.0-24457397.ova"
# Ensure that the machine running this script has fast network connection to the vCenter server.
# This is important for the OVA file upload - which can be >5GB in size - to the content library item in less time.
$applianceFilePath = "C:\Users\jumpboxadmin\Downloads\VMware-HCX-Connector-4.11.0.0-24457397.ova"

# $hcxUrl parameter represents the HCX Connector URL.
# It is the URL where the HCX Connector will be accessible after deployment.
# It should be the IP address or FQDN of the HCX Connector VM.
# Make sure to include the port number (9443) and trailing slash.
# Conventionally, .9 in fourth octet is used for HCX Connector VM.
# Example: "https://hcx.example.com:9443/" or "https://10.1.1.9:9443/"
$hcxUrl = "https://10.1.1.9:9443/"

# $segmentName parameter represents the name of the network segment where the HCX Connector will be deployed.
# It is used to specify the network segment for the HCX Connector VM.
# This segment should be pre-configured in the vCenter environment.
# Example: "OnPrem-management-1-1"
$segmentName = "OnPrem-management-1-1"

# $applianceVMName parameter represents the name of the HCX Connector VM.
# It is used to identify the HCX Connector VM in the vCenter environment.
# This name should be unique within the vCenter environment.
# Example: "HCX-Connector-VM"
$applianceVMName = "HCX-Connector-VM2"

# $applianceVMIP parameter represents the IP address of the HCX Connector VM.
# It is used to assign a static IP address to the HCX Connector VM.
# This IP address should be within the network segment specified by $segmentName.
# Example: "10.1.1.9"
# Note: Ensure that this IP address is not already in use in the network segment.
# It is recommended to use .9 in fourth octet for HCX Connector VM.
$applianceVMIP = "X.Y.Z.9"

# $applianceVMGatewayIP parameter represents the gateway IP address for the HCX Connector VM.
# It is used to specify the gateway for the HCX Connector VM.
# This IP address should be the gateway of the network segment specified by $segmentName.
# Example: "10.1.1.1"
$applianceVMGatewayIP = "X.Y.Z.1"

# $hcxAdminGroup parameter represents the Active Directory group that will be granted administrative access to HCX.
# It is used to configure HCX role mappings for the specified group.
# This group should already exist in the Active Directory environment.
# Example: "avs.lab\Administrators"
$hcxAdminGroup = "avs.lab\Administrators"

# $hcxLicenseKey parameter represents the HCX license key.
# It is used to activate HCX Connector.
# This key should be obtained from Azure VMware Solution after enabling HCX Add-on.
# It is required for HCX Connector to function.
# # Example: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
# Note: This key is specific to the Azure VMware Solution HCX Add-on and should not be shared publicly.
$hcxLicenseKey = "<REPLACE_WITH_HCX_LICENSE_KEY>"
