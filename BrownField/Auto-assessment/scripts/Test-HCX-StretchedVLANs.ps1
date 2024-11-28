function Test-HCX-StretchedVLANs {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get AVS Credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Define API URL 
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/l2Extensions",
            $sddcDetails.hcxUrl
        )

        # Make the request
        $response = Invoke-APIRequest -method "GET" `
            -url $apiUrl `
            -avsHcxUrl $sddcDetails.hcxUrl `
            -avsvCenteruserName $credentials.vCenterUsername `
            -avsvCenterpassword $credentials.vCenterPassword

        # Process the response
        if ($response) {
             foreach ($l2Extension in $response.items) {
                # If the creationDate is older than 30 days, then create a new recommendation
                if ((Get-Date) - (Get-Date $l2Extension.creationDate) -gt (New-TimeSpan -Days 30)) {
                    $recommendationType = "VLANStretchedForMoreThan30Days"
                    break
                }
             }    
        }else {
            $recommendationType = "VLANStretchedForMoreThan30Days"
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "Test HCX Stretched VLANs Failed: $_"
    }
}