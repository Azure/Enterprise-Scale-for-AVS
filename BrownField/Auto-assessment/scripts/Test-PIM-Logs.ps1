function Test-PIM-Logs {
    param (
        [SecureString]$graphToken,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        #$sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define API endpoint
        $apiUrl = "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$filter=loggedByService eq 'PIM'"
        #$apiUrl = [string]::Format("https://management.azure.com/providers/Microsoft.AuditLogs/directoryAudits?" +
                    #"api-version=2017-03-01-preview&`$filter=loggedByService eq 'PIM'")

        # Make the request
        $response = Invoke-APIRequest `
                            -method "Get" `
                            -url $apiUrl `
                            -token $graphToken

        # Check if the PIM logs are empty
        $recommendationType = if ($null -eq $response -or $response.value.Count -eq 0) {
            "NoPIMLogs"        
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "PIM Logs Test failed: $_"
    }
} 