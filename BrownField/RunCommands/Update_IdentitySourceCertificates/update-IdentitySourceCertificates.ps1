<#
.SYNOPSIS
    Uses the AVS run command to update ldaps identity source certificates.
.DESCRIPTION
    This cmdlet updates ldaps identity source certificates for a specified domain by running the AVS run command 'Update-IdentitySourceCertificates' with the domain name for the target domain. 
.PARAMETER SubscriptionId
    The ID of the Azure subscription where the AVS Private Cloud is located
.PARAMETER PrivateCloudResourceGroup
    The Resource Group of the AVS Private Cloud
.PARAMETER PrivateCloudName
    The name of the AVS Private Cloud
.PARAMETER DomainName
    The name of the domain for which the ldaps identity source certificates must be updated 
.EXAMPLE
    .\update-IdentitySourceCertificates.ps1 -SubscriptionID "00000000-000-0000-0000-000000000000" -PrivateCloudResourceGroup AVS-RG -PrivateCloudName MYAVSPRIVATECLOUD  -DomainName "test.local"

#>
param(
    [Parameter(Mandatory=$true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [String]$PrivateCloudResourceGroup,

    [Parameter(Mandatory=$true)]
    [String]$PrivateCloudName,

    [Parameter(Mandatory=$true)]
    [Array]$DomainName
)

$runCommandName = 'Update-IdentitySourceCertificates'

# Define the module name
$ModuleName = "Az"

# Check if the module is already installed
$InstalledModule = Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue

# Find the latest version available in the repository
$LatestModule = Find-Module -Name $ModuleName

if ($LatestModule) {
    if (-not $InstalledModule -or $LatestModule.Version -gt $InstalledModule.Version) {
        Write-Host "Installing or updating $ModuleName to version $($LatestModule.Version)..."
        Install-Module -Name $ModuleName -Force -AllowClobber -Scope CurrentUser
    } else {
        Write-Host "$ModuleName is already up-to-date (version $($InstalledModule.Version))."
    }
} else {
    Write-Host "Module $ModuleName not found in the repository."
}

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity

$datestring  = Get-Date -Format "MM-dd-yyyy-HH-mm"

$body = @"
{
  "properties": {
    "scriptCmdletId": "/subscriptions/$SubscriptionId/resourceGroups/$PrivateCloudResourceGroup/providers/Microsoft.AVS/privateClouds/$privateCloudName/scriptPackages/Microsoft.AVS.Management@7.0.175/scriptCmdlets/$runCommandName",
    "timeout": "P0Y0M0DT0H60M60S",
    "retention": "P0Y0M60DT0H60M60S",
    "parameters": [
      {
        "name": "DomainName",
        "type": "Value",
        "value": "$DomainName"
      }
    ]
  }
}
"@

$token = (Get-AzAccessToken -ResourceTypeName Arm -AsSecureString).Token

$convertToken = [System.Runtime.InteropServices.Marshal]::SecureStringtoBSTR($token)
$plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($convertToken)

$headers = @{
    'Authorization' = "Bearer $plainToken"
}

$url = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$PrivateCloudResourceGroup/providers/Microsoft.AVS/privateClouds/$privateCloudName/scriptExecutions/$runCommandName-$datestring\?api-version=2024-09-01"

Invoke-RestMethod -Uri $url -Method PUT -Headers $headers -Body $body -ContentType "application/json" -Verbose