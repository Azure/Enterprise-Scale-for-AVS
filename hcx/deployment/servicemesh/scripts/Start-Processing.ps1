. .\Install-IfNotExist-RequiredModules.ps1
. .\Get-Tokens.ps1
. .\Get-AVS-SDDC-Details.ps1
. .\New-IfNotExists-HCX-Pairing.ps1
. .\New-IfNotExists-HCX-NetworkProfiles.ps1
. .\New-IfNotExists-HCX-ComputeProfile.ps1
. .\New-IfNotExists-HCX-ServiceMesh.ps1
. .\Get-Interconnect-Capabilities.ps1
function Start-Processing {
    param (
        [string]$ParameterFile,
        [secureString]$hcxConnectorPassword
    )
    
    # Source the parameter file inside the function to get access to all parameters
    . $ParameterFile

    # Install required modules if not already installed
    Install-IfNotExist-RequiredModules

    # Get the Azure Beaer token
    $tokens = Get-Tokens -TenantID $tenantId -SubscriptionID $subscriptionId

    if (-not $tokens -or -not $tokens.secureToken) {
        Write-Error "Failed to retrieve tokens."
        return $false
    }

    # Get the AVS SDDC Details
    $sddcDetails = Get-AVS-SDDC-Details -token $tokens.secureToken `
                        -subscriptionId $subscriptionId `
                        -avsSddcName $avsSddcName

    if (-not $sddcDetails) {
        Write-Error "Failed to retrieve AVS SDDC details."
        return $false
    }

    # Check and create HCX pairing
    $pairing = New-IfNotExists-HCX-Pairing -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
        -hcxConnectorUserName $hcxConnectorUserName `
        -hcxConnectorPassword $hcxConnectorPassword `
        -hcxManager $sddcDetails.hcxUrl `
        -hcxManagerUserName $sddcDetails.vCenterUserName `
        -hcxManagerPassword $sddcDetails.vCenterPassword


    if (-not $pairing) {
        Write-Error "Failed to create or retrieve HCX pairing."
        return $false
    }

    # Check and create HCX Network Profile
    $hcxNetworkProfiles = New-IfNotExists-HCX-NetworkProfiles -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
        -hcxConnectorUserName $hcxConnectorUserName `
        -hcxConnectorPassword $hcxConnectorPassword

    if (-not $hcxNetworkProfiles -or $hcxNetworkProfiles.Count -lt 4) {
        Write-Error "Failed to create or retrieve necessary HCX Network Profiles."
        return $false
    }
    
    # Check and create HCX Compute Profile
    $computeProfile = New-IfNotExists-HCX-ComputeProfile -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
        -hcxConnectorUserName $hcxConnectorUserName `
        -hcxConnectorPassword $hcxConnectorPassword `
        -hcxNetworkProfiles $hcxNetworkProfiles

    if (-not $computeProfile) {
        Write-Error "Failed to create or retrieve HCX Compute Profile."
        return $false
    }

    # Check and create HCX Service Mesh
    $serviceMesh = New-IfNotExists-HCX-ServiceMesh -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
        -hcxConnectorUserName $hcxConnectorUserName `
        -hcxConnectorPassword $hcxConnectorPassword `
        -hcxPairing $pairing `
        -hcxComputeProfile $computeProfile

    if (-not $serviceMesh) {
        Write-Error "Failed to create or retrieve HCX Service Mesh."
        return $false
    }
    
    return $true
}