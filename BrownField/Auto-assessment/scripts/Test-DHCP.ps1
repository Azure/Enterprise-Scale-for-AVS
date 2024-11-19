. ./Get-DHCP-NSXT.ps1
. ./Get-DHCP-Azure.ps1
function Test-DHCP {
    param(
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get DHCP configuration from NSXT
        $nsxTdhcp = Get-DHCP-NSXT -token $token -sddc $sddc

        # Get DHCP configuration from Azure
        $azuredhcp = Get-DHCP-Azure -token $token -sddc $sddc

        # Process the response
        $recommendationType = if ($nsxTdhcp -and `
                $azuredhcp -and `
                ($azuredhcp.value -or `
                $nsxTdhcp.results))
        {
            if ($nsxTdhcp.results.Count -eq 0 -and `
                $azuredhcp.value.Count -eq 0) {
                "NoDHCP"
            }
            else {
                "CustomDHCP"
            }
        }
        
        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Error "DHCP Test failed: $_"
    }
}