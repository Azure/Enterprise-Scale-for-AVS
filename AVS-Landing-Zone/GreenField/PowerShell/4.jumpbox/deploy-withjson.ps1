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
$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json
$jumpbox = $variables.jumpbox
$networking = $variables.Networking

##Global variables

$resourceGroupLocation = $jumpbox.location
$jumpboxRgName = $jumpbox.resourcegroupname
$networkingRgName = $networking.hubAndSpoke.resourcegroupname

## Azure bastion Variables
$pipName = $jumpbox.bastion.pip.name
$pipSKU = $jumpbox.bastion.pip.sku 
$pipAllocationMethod = $jumpbox.bastion.pip.pipallocationmethod
$pipIpAddressVersion = $jumpbox.bastion.pip.ipaddressversion
$bastionName = $jumpbox.bastion.name
$vnetName = $networking.hubAndSpoke.hubvnetname
$vnetLocation = $networking.hubAndSpoke.location

$ip = @{
    Name = $pipName
    ResourceGroupName = $jumpboxRgName
    Location = $vnetLocation
    Sku = $pipSKU 
    AllocationMethod = $pipAllocationMethod
    IpAddressVersion = $pipIpAddressVersion
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

$deployJumpbox = $jumpbox.deploy 
if ($deployJumpbox -eq "true") {
    ## Password field, update as needed
    $password = Read-Host "Enter a Password" -AsSecureString
    $vmSize = $jumpbox.vmsize
    #$vmName = "jumpbox-vm1"
    $computerName = $jumpbox.name
    $vmUsername = $jumpbox.username

    $vmCreds = New-Object System.Management.Automation.PSCredential($vmUsername, $password)
    $vmLocation = $jumpbox.location
    $vmResourceGroupName = $jumpbox.resourcegroupname
    $vmPublisherName = $jumpbox.vmpublishername
    $vmOfferName = $jumpbox.vmoffername
    $vmOSEdition = $jumpbox.vmosedition
    $vmOSVersion = $jumpbox.vmosversion


    $vmSubnetName = $networking.hubAndSpoke.subnets.frontend.name
    $vmSubnet = $vnet.Subnets | Where-Object {$_.name -eq $vmSubnetName}
    $vmSubnetId = $vmSubnet.id

    # Create the vm NIC
    $vmNic = New-AzNetworkInterface -Name "$computerName-nic1" -ResourceGroupName $jumpboxRgName -Location $resourceGroupLocation -SubnetId $vmSubnetId

    # Create the virtual machine configuration object
    $VirtualMachine = New-AzVMConfig -VMName $computerName -VMSize $vmSize

    $deployVmBootDiagnostics = $jumpbox.vmbootdiagnostics.deploy

    if ($deployVmBootDiagnostics -eq "true") {

        $guid = New-Guid
        $vmBootDiagnosticsSaName = $jumpbox.vmbootdiagnostics.vmbootdiagnosticsstorageaccountname
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