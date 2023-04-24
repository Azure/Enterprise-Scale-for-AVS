###############################################
#                                             #
#  Author : Fletcher Kelly                    #
#  Github : github.com/fskelly                #
#  Purpose : AVS - Deploy jumpbox sample      #
#  Built : 11-July-2022                       #
#  Last Tested : 02-August-2022               #
#  Language : PowerShell                      #
#                                             #
###############################################

## Important link around azure-partner-customer-usage-attribution
## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers

<# 
Notification for SDK or API deployments
When you deploy <PARTNER> software, Microsoft can identify the installation of <PARTNER> software with the deployed Azure resources. Microsoft can correlate these resources used to support the software. Microsoft collects this information to provide the best experiences with their products and to operate their business. The data is collected and governed by Microsoft's privacy policies, located at https://www.microsoft.com/trustcenter. 
#>

## Telemetry enabled by default, Can be disabled by change the value of the telemetry parameter to false
$telemetry = $true

if ($telemetry) {
  ## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers
    Write-Output "Telemetry enabled"
    $telemetryId = "pid-e3bf694a-443e-475c-a0ef-ab3bc9990338"
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($telemetryId)
} else {
    Write-Host "Telemetry disabled"
}

##Global variables
$technology = "avs"
$resourceGroupLocation = "germanywestcentral"
$jumpboxRgName = "$technology-$resourceGroupLocation-jumpbox_rg"
$networkingRgName = "$technology-$resourceGroupLocation-networking_rg"

## Azure bastion Variables
$pipName = "$technology-$resourceGroupLocation--bastion-pip1"
$pipSKU = "Standard"
$pipAllocationMethod = "Static"
$bastionName = "$technology-$resourceGroupLocation-bastion1"
$vnetName = "$technology-$resourceGroupLocation-vnet1"
$vnetLocation = "germanywestcentral"

$jumpboxRgName = "$technology-$resourceGroupLocation-jumpbox_rg"
$networkingRgName = "$technology-$resourceGroupLocation-networking_rg"

$ip = @{
    Name = $pipName
    ResourceGroupName = $jumpboxRgName
    Location = $vnetLocation
    Sku = $pipSKU 
    AllocationMethod = $pipAllocationMethod
    IpAddressVersion = 'IPv4'
    Zone = 1,2,3
}

## Azure bastion deployment
$bastionPublicIp = New-AzPublicIpAddress @ip
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $networkingRgName

$bastionConfig = @{
    ResourceGroupName = $jumpboxRgName
    Name = $bastionName
    PublicIpAddress = $bastionPublicIp
    VirtualNetwork = $vnet
}
## Deploy bastion
$bastion = New-AzBastion @bastionConfig

## Deploy jumpbox
## update password as needed
$password = ""

$deployJumpbox = $false
if ($deployJumpbox) {
    ## Password field, update as needed
    $userPassword = ""
    $vmSize = "Standard_D2s_v3"
    #$vmName = "jumpbox-vm1"
    $computerName = "jumpbox-vm2"
    $vmUsername = "avsjump"
    $vmPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

    $vmCreds = New-Object System.Management.Automation.PSCredential($vmUsername, $vmPassword)
    $vmLocation = "germanywestcentral"
    $vmResourceGroupName = "$technology-$resourceGroupLocation-jumpbox_rg"
    $vmPublisherName = "MicrosoftWindowsServer"
    $vmOfferName = "WindowsServer"
    $vmOSEdition = "2019-Datacenter-smalldisk"
    $vmOSVersion = "latest"
    $deployVmBootDiagnostics = $false

    $vmSubnet = $vnet.Subnets | Where-Object {$_.name -eq "frontend"}
    $vmSubnetId = $vmSubnet.id

    # Create the vm NIC
    $vmNic = New-AzNetworkInterface -Name "$computerName-nic1" -ResourceGroupName $jumpboxRgName -Location $resourceGroupLocation -SubnetId $vmSubnetId

    # Create the virtual machine configuration object
    $VirtualMachine = New-AzVMConfig -VMName $computerName -VMSize $vmSize

    if ($deployVmBootDiagnostics) {

        $guid = New-Guid
        $vmBootDiagnosticsSaName = "vmbootdiag"
        $vmBootDiagnosticsSaSuffix = $guid.ToString().Split("-")[0]
        $vmBootDiagnosticsSaName = (($vmBootDiagnosticsSaName.replace("-",""))+$vmBootDiagnosticsSaSuffix)

        #does boot diagnostics storage account exist?
        $vmBootDiagnosticsSa = Get-AzStorageAccount -ResourceGroupName $vmResourceGroupName -Name $vmBootDiagnosticsSaName -ErrorAction SilentlyContinue

        if ($null -ne $vmBootDiagnosticsSa) {
            Set-AzVMBootDiagnostic -VM $VirtualMachine -Enable -ResourceGroupName $vmResourceGroupName -StorageAccountName $vmBootDiagnosticsSaName
        } else {

            $vmBootDiagnosticsSa = New-AzStorageAccount -ResourceGroupName $vmResourceGroupName -Name $vmBootDiagnosticsSaName -Location $vmLocation -AccountType Standard_LRS
            Set-AzVMBootDiagnostic -VM $VirtualMachine -Enable -ResourceGroupName $vmResourceGroupName -StorageAccountName $vmBootDiagnosticsSaName
        }
    }

    # Set the VM Size and Type
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -ComputerName $computerName -Credential $vmCreds -Windows
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $vmNic.Id
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $vmPublisherName -Offer $vmOfferName -Skus $vmOSEdition -Version $vmOSVersion
    New-AzVM -ResourceGroupName $vmResourceGroupName -Location $vmLocation -VM $VirtualMachine
}