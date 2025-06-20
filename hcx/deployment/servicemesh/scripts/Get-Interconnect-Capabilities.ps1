. .\Invoke-API.ps1

function Get-Interconnect-Capabilities {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/capabilities",
            $hcxConnectorServiceUrl
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
        Write-Error "Error retrieving interconnect capabilities: $_"
    }
}

function Get-SitePair-Capabilities {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/capabilities/site-pair-capabilities",
            $hcxConnectorServiceUrl
        )

        # Define the body
        $body = @{
            source_endpoint_id = "20250606141804337-10615006-abbc-464e-876c-66c0a70f27dd"
            dest_endpoint_id = "20250522180456277-46f92f26-8a2d-4815-941c-245300dc59b4"
        }

        $jsonBody = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-API -method "POST" `
            -url $apiUrl `
            -body $jsonBody `
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
        Write-Error "Error retrieving interconnect capabilities: $_"
    }
}