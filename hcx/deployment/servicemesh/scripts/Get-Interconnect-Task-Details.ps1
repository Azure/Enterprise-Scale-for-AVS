. .\Invoke-API.ps1
function Get-Interconnect-Task-Details {
    param (
        [Parameter(Mandatory = $true)]
        [string]$taskID,
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/tasks/{1}",
            $hcxConnectorServiceUrl, $taskID
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
            Write-Error "No task details found or failed to retrieve."
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving task details: $_"
    }
}