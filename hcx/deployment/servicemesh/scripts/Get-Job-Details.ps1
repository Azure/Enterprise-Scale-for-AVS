. .\Invoke-API.ps1
function Get-Job-Details {
    param (
        [Parameter(Mandatory = $true)]
        [string]$jobId,
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/jobs/{1}",
            $hcxConnectorServiceUrl, $jobId
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response) {
            return $response
        } else {
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving job details: $_"
    }
}