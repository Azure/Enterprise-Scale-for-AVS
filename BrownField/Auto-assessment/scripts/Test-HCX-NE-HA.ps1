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
            foreach ($serviceMesh in $response.items) {
                # Make API call to get HA Groups
                $haGroupStatus = Get-HA-Group -sddcDetails $sddcDetails `
                    -credentials $credentials `
                    -serviceMeshId $serviceMesh.serviceMeshId

                # If HA Group is not present, add recommendation and break
                if ($haGroupStatus -eq $false) {
                    $recommendationType = "NoHCXNEHA"
                    break
                }
            } 
        }else {
            $recommendationType = "NoHCXNEHA"
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

function Get-HA-Group {
    param (
        [PSCustomObject]$sddcDetails,
        [PSCustomObject]$credentials,
        [string]$serviceMeshId
    )

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "hybridity/api/interconnect/appliances/ha/groups?serviceMeshId={1}",
        $sddcDetails.hcxUrl,
        $serviceMeshId
    )

    # Make the request
    $response = Invoke-APIRequest -method "GET" `
                    -url $apiUrl `
                    -avsHcxUrl $sddcDetails.hcxUrl `
                    -avsvCenteruserName $credentials.vCenterUsername `
                    -avsvCenterpassword $credentials.vCenterPassword

    # Process the response
    if ($response) {
        if ($response.items.Count -eq 0) {
            return $false
        }
    }
}