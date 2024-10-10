function Get-vCenter-Credentials {
    param (
        [string]$token
    )

    # Define the API endpoint for AVS credentials
    $apiUrl = [string]::Format(
        "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/listAdminCredentials?api-version=2023-09-01", 
        $subscriptionId, 
        $AVSSDDCresourceGroupName, 
        $privateCloudName
    )

    #Write-Output $apiUrl

    # Make the API request for AVS credentials
    Write-Host "Requesting AVS credentials..."
    $response = Invoke-APIRequest -method "Post" `
                          -url $apiUrl `
                          -token $token

    if ($null -eq $response) {
        Write-Error "Failed to get AVS credentials."
        return
    }

    $securevcenterPassword = $response.vcenterPassword.Trim() | ConvertTo-SecureString -AsPlainText -Force
    $securensxtPassword = $response.nsxtPassword.Trim() | ConvertTo-SecureString -AsPlainText -Force
    Write-Host "Secure passwords obtained."

    return @{
        vCenterUsername = $response.vcenterUsername.Trim()
        vCenterPassword = $securevcenterPassword
        nsxtUsername = $response.nsxtUsername.Trim()
        nsxtPassword = $securensxtPassword
    }
}