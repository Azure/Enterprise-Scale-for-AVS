function Test-EntraID-DiagSetting {
    param (
        [SecureString]$token
    )

    try {
        # Define API endpoint
        $apiUrl = [string]::Format(
            "https://management.azure.com/providers/microsoft.aadiam/diagnosticSettings?api-version=2017-04-01-preview"
        )

        # Make the request
        $response = Invoke-APIRequest `
                            -method "Get" `
                            -url $apiUrl `
                            -token $token

        # Check the response
        $recommendationType = if ($null -eq $response -or $response.value.Count -eq 0) {
            "NoEntraIDDiagnostics"        
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "Entra ID Diagnostic setting Test failed: $_"
    }
} 