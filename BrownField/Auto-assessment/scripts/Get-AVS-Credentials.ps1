function Get-AVS-Credentials {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    # Get AVS SDDC details
    $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

    # Define the API endpoint
    $apiUrl = [string]::Format(
        "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/" +
        "providers/Microsoft.AVS/privateClouds/{2}/listAdminCredentials?api-version=2023-09-01", 
        $sddcDetails.subscriptionId, 
        $sddcDetails.resourceGroupName, 
        $sddcDetails.sddcName
    )

    # Make the API request
    $response = Invoke-APIRequest -method "Post" `
                          -url $apiUrl `
                          -token $token

    if ($null -eq $response) {
        Write-Error "Failed to get AVS credentials."
        return
    }

    $securevcenterPassword = $response.vcenterPassword.Trim() | ConvertTo-SecureString -AsPlainText -Force
    $securensxtPassword = $response.nsxtPassword.Trim() | ConvertTo-SecureString -AsPlainText -Force

    return @{
        vCenterUsername = $response.vcenterUsername.Trim()
        vCenterPassword = $securevcenterPassword
        nsxtUsername = $response.nsxtUsername.Trim()
        nsxtPassword = $securensxtPassword
    }
}