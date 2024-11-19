function Test-ContentLibrary {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {

        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get Credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Define the API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/content/library",
            $sddcDetails.vCenterUrl
        )

        # Make API call
        $librariesresponse = Invoke-APIRequest -method "GET" `
                    -url $apiUrl `
                    -avsVcenter $sddcDetails.vCenterUrl `
                    -avsvCenterUserName $credentials.vCenterUsername `
                    -avsvCenterPassword $credentials.vCenterPassword

        # Process the response
        if ($librariesresponse -and $librariesresponse.Count -gt 0) {
            foreach ($library in $librariesresponse) {
            # Define API URL to get Details of the Content Library
            $contentLibraryapiUrl = "$($sddcDetails.vCenterUrl)api/content/library/$library"

            # Make API call
            $contentLibraryresponse = Invoke-APIRequest -method "GET" `
                    -url $contentLibraryapiUrl `
                    -avsVcenter $sddcDetails.vCenterUrl `
                    -avsvCenterUserName $credentials.vCenterUsername `
                    -avsvCenterPassword $credentials.vCenterPassword

            # Process the response
            if ($contentLibraryresponse -and $contentLibraryresponse.type -eq "LOCAL") {
                if ($contentLibraryresponse.storage_backings | Where-Object { $_.type -eq "DATASTORE" }) {
                $recommedationType = "vSANForContentLibrary"
                break
                }
            }
            }
        }
        
        # Add the recommendation
        if ($recommedationType) {
            $recommendation = Get-Recommendation -type $recommedationType -sddcName $sddcDetails.sddcName
            $Global:recommendations += $recommendation
        }
    }
    catch {
        Write-Error "Content Library Test failed: $_"
    }
}