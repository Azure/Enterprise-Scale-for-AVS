function Test-HCX-NE-HA {
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
            "hybridity/api/interconnect/serviceMesh",
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
            
        }else {
            $recommendationType = "NoHCXServiceMesh"
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "Test HCX Network Extension HA Failed: $_"
    }
}