function Test-NSXT-GatewayFirewall {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {

        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get the NSX-T credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Define the API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "policy/api/v1/search/aggregate?page_size=50&cursor=0" +
            "&sort_by=display_name&sort_ascending=true",
            $sddcDetails.nsxtUrl
        )

        # Define the body
        $body = @{
            primary = @{
                resource_type = "Tier1 OR Tier0"
            }
            related = @(
                @{
                    resource_type = "SecurityFeatures"
                    join_condition = "parent_path:path"
                    alias = "security_features"
                },
                @{
                    resource_type = "Tier0SecurityFeatures"
                    join_condition = "parent_path:path"
                    alias = "tier0_security_features"
                }
            )
        }

        $body = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-APIRequest -method "POST" `
            -url $apiUrl `
            -avsnsxtUserName $credentials.nsxtUsername `
            -avsnsxtPassword $credentials.nsxtPassword `
            -body $body

        # Process the response
        if ($response -and $response.results -and $response.results.Count -gt 0) {
            $counter = ($response.results | Where-Object { $_.primary.disable_firewall -eq $false }).Count

            if ($counter -ne $response.results.Count) {
            $recommendationType = "DisabledGatewayFirewall"
            }
        }
        
        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Host "NSX-T Traffic Filtering Test failed: $_"
    }
}