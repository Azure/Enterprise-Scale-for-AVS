function Get-VMware-API-Session-Id {
    param (
        [string]$avsVcenter,
        [string]$userName,
        [string]$Password
    )

    # Encode credentials
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${userName}:${Password}"))

    # Define the vmware-api-session-id API endpoint
    $url = [string]::Format(
        $avsVcenter + "/api/session/" 
    )
    
    try {
            # Make the API request
            $response = Invoke-RestMethod -Uri $url -Method Post -Headers @{ 
                Authorization = ("Basic {0}" -f $base64AuthInfo)
                'Content-Type' = 'application/json'
            } -SkipCertificateCheck

            # Return the response
            return $response
    } catch {
        Write-Error "Error occurred while connecting to AVS vCenter: $_"
        return $null
    }

}