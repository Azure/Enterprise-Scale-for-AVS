<#
.SYNOPSIS
    Applies a Storage Policy to a set of AVS Virtual Machines.
.DESCRIPTION
    This cmdlet applies a Storage Policy to a set of AVS Virtual Machines by running the AVS command 'Set-VMStoragePolicy' for each VM name provided in the VmNames input parameter. 
.PARAMETER PrivateCloudName
    The name of the AVS Private Cloud
.PARAMETER PrivateCloudResourceGroup
    The Resource Group of the AVS Private Cloud
.PARAMETER StoragePolicyName
    The name of an existing Storage Policy in the AVS Private Cloud
.PARAMETER VmNames
    An array of names of existing AVS VMs to which the Storage Policy must be applied    
.EXAMPLE
    .\setStoragePolicy.ps1 -PrivateCloudName MYAVSPRIVATECLOUD -PrivateCloudResourceGroup AVS-RG -StoragePolicyName "Thin Provision" -VmNames 'VmProd1','VmTest1','VmTest2'
.EXAMPLE    
    .\setStoragePolicy.ps1 -PrivateCloudName MYAVSPRIVATECLOUD -PrivateCloudResourceGroup AVS-RG -StoragePolicyName "Thin Provision" -VmNames @('VmProd1','VmTest1','VmTest2')
#>
param(
    [Parameter(Mandatory=$true)]
    [String]$PrivateCloudName,

    [Parameter(Mandatory=$true)]
    [String]$PrivateCloudResourceGroup,

    [Parameter(Mandatory=$true)]
    [String]$StoragePolicyName,

    [Parameter(Mandatory=$true)]
    [Array]$VmNames
)

# Package name
$packageName = 'Microsoft.AVS.Management'

# Cmdlet name
$cmdletName = 'Set-VMStoragePolicy'

# Find package 
$package = az vmware script-package list --resource-group $PrivateCloudResourceGroup --private-cloud $PrivateCloudName --query "[? contains(name,'$packageName')].name" -o tsv

# If package exists
if ($null -ne $package -and $package.StartsWith($packageName)) {
    $packageVersion = $package.Substring($package.IndexOf('@')+1)
    
    # Find cmdlet in package
    $cmdlet = az vmware script-cmdlet list --script-package $package --resource-group $PrivateCloudResourceGroup --private-cloud $PrivateCloudName --query "[? contains(name,'$cmdletName')].name" -o tsv
    
    # If cmdlet exists in package
    if ($null -ne $cmdlet -and $cmdlet.Equals($cmdletName)) {
        $cmdletId = "$packageName/$packageVersion/$cmdletName"

        foreach ($vm in $VmNames) {
            $guid = new-guid
            $vm = $vm.trim()
            $execname = "$cmdletname-$vm-$guid"
            Write-Host "Invoking cmdlet $cmdletName on VM: $vm."
            az vmware script-execution create --name $execname --resource-group $PrivateCloudResourceGroup --private-cloud $PrivateCloudName --script-cmdlet-id $cmdletId --timeout P0Y0M0DT0H60M0S --parameter name=VMName type=Value value=$vm --parameter name=StoragePolicyName type=Value value=$StoragePolicyName 2> $null
        }
    }
    # Cmdlet does not exist in package
    else {
        Write-Error "Cmdlet $cmdletName does not exist in package $package!"
    }
}
# Package does not exist
else {
    Write-Error "Package $packageName does not exist in Private Cloud $PrivateCloudName!"
}