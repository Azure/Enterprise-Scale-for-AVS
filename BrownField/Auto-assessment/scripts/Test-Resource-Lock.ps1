function Test-Resource-Lock {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {

        #Get SDDC Details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define the API URL
        $resourceLockApiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/" +
            "providers/Microsoft.Authorization/locks?api-version=2016-09-01",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName,
            $sddcDetails.sddcName
        )

        # Make the API request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $resourceLockApiUrl `
                        -token $token

        # Process the response
        if ($null -eq $response -or $null -eq $response.value -or $response.value.Count -lt 1) {
            $Global:recommendations += Get-Recommendation -type "NoResourceLock" -sddcName $sddcDetails.sddcName
        }
        
    }
    catch {
        Write-Error "Resource Lock Test failed: $_"
    }
}