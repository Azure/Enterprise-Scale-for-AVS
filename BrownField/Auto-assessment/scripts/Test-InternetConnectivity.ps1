. ./Test-NSXTPIP.ps1
function Test-InternetConnectivity {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Determine the recommendation type
        $recommendationType = if ($sddc -and $sddc.properties) {
            if ($sddc.properties.internet -eq "Disabled") {
                "NoManagedSNAT"
            } else {
                Test-NSXTPIP -token $token -sddc $sddc
            }
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) 
        { $Global:recommendations += Get-Recommendation -type $recommendationType `
                                            -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "GlobalReach Test failed: $_"
    }
}