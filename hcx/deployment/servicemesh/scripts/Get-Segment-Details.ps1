. .\Invoke-API.ps1
function Get-Segment-Details {
    param (
        [string]$hcxConnectorvCenter,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [string]$segmentName
    )

    try {
       # Create API Endpoint
        $segmentUrl = [string]::Format(
            "{0}" +
            "api/vcenter/network",
            $hcxConnectorvCenter
        )

        # Make the request
        $response = Invoke-API -method "Get" `
                                    -url $segmentUrl `
                                    -vCenter $hcxConnectorvCenter `
                                    -userName $hcxConnectorUserName `
                                    -password $hcxConnectorPassword `
                                    -AuthType "vSphereCISSession"
        if ($response) {
            # Check if the response contains the segment with the specified name
            $segment = $response | Where-Object { $_.name -eq $segmentName }
            if ($segment) {
                # Return the Segment ID
                return $segment
            } else {
                Write-Error "Failed to get Segment ID."
                return $null
            }
        }
    }
    catch {
        Write-Error "Error retrieving Segment ID: $_"
    }
}