function Test-vSAN-encryption {
    param (
        [PSCustomObject]$sddc
    )

    try {
        # Determine the recommendation type
        $recommendationType = if ($sddc -and `
                $sddc.properties -and `
                $sddc.properties.encryption.status -eq "Disabled") {
            "NovSANEncryption"
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "vSAN encryption Test failed: $_"
    }
}