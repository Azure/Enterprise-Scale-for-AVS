function Test-ERGateway {
    param(
        [SecureString]$token,
        [PSCustomObject]$sddc,
        [System.Object[]]$allgatewayConnections        
    )
    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc
            
        # Define the API URL
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/" +
            "authorizations?api-version=2023-09-01",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName
        )

        # Make the request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $apiUrl `
                        -token $token

        # Process the response
        if ($response -and $response.value -and $response.value.Count -gt 0) {
            # Fiter the successful redemptions
            $successfulRedemptions = $response.value | Where-Object { $_.properties.provisioningState -eq "Succeeded" }

            if ($successfulRedemptions.Count -gt 0) {
                $filteredConnections = $allgatewayConnections | Where-Object { 
                    $_.properties.peer.id -eq $sddc.Properties.circuit.expressRouteID
                }
                
                foreach ($connection in $filteredConnections) {
                    try {
                        Test-ERGateway-SKU -connection $connection `
                                                    -token $token
                    }
                    catch {
                        Write-Error "Error in ER Gateway Test: $_"
                    }
                }

            }
        }   
    }
    catch {
        Write-Error "ER Gateway Test failed: $_"
    }
}

function Test-ERGateway-SKU {
    param (
        [PSCustomObject]$connection,
        [SecureString]$token
    )

    $gatewayId = $connection.properties.virtualNetworkGateway1.id

    # Define the API URL
    $gatewayApiUrl = "https://management.azure.com$($gatewayId)?api-version=2024-03-01"

    # Make the API request
    $gatewayResponse = Invoke-APIRequest `
                        -method "Get" `
                        -url $gatewayApiUrl `
                        -token $token

    # Process the response
    if ($gatewayResponse) {
        # Determine the gateway properties
        $sku = $gatewayResponse.properties.sku

        if ($sku) {
            switch ($sku.name) {
                "Standard" {
                    $Global:recommendations += Get-Recommendation -type "NonZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "NonFastPathGateway" `
                                                -sddcName $sddcDetails.sddcName

                    break
                }
                "HighPerformance" {
                    $Global:recommendations += Get-Recommendation -type "NonZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "NonFastPathGateway" `
                                                -sddcName $sddcDetails.sddcName

                    break
                }
                "UltraPerformance" {
                    $Global:recommendations += Get-Recommendation -type "NonZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "FastPathGateway" `
                                                -sddcName $sddcDetails.sddcName
                    break
                }
                "ErGw1Az" {
                    $Global:recommendations += Get-Recommendation -type "ZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "NonFastPathGateway" `
                                                -sddcName $sddcDetails.sddcName

                    break
                }
                "ErGw2Az" {
                    $Global:recommendations += Get-Recommendation -type "ZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "NonFastPathGateway" `
                                                -sddcName $sddcDetails.sddcName

                    break
                }
                "ErGw3Az" {
                    $Global:recommendations += Get-Recommendation -type "ZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "FastPathGateway" `
                                                -sddcName $sddcDetails.sddcName

                    break
                }
                default {
                    $Global:recommendations += Get-Recommendation -type "NonZoneRedundantGateway" `
                                                -sddcName $sddcDetails.sddcName
                    $Global:recommendations += Get-Recommendation -type "NonFastPathGateway" `
                                                -sddcName $sddcDetails.sddcName

                    break
                }
            }

            # Test DDoS protection plan for the current VNet
            Test-ERGatewayVNet-DDoS-Protection -token $token `
                                -subnetResourceId $gatewayResponse.properties.ipConfigurations[0].properties.subnet.id

            # Test utilization for the current gateway
            Test-ERGateway-Connection-Utilization -token $token `
                                -connectionId $connection.id `
                                -sku $sku.name
        }
    }
}

function Test-ERGatewayVNet-DDoS-Protection {
    param (
        [SecureString]$token,
        [string]$subnetResourceId
    )

    # Get VNet from $subnetResourceId
    $vnetResourceId = $subnetResourceId -replace "/subnets/.*", ""

    # Define the API URL to get DDoS protection plan for the current VNet
    $ddosProtectionPlanApiUrl = "https://management.azure.com$vnetResourceId/ddosProtectionStatus?api-version=2024-03-01"

    # Make the API request to get DDoS protection plan for the current VNet
    $ddosResponse = Invoke-APIRequest `
                        -method "Get" `
                        -url $ddosProtectionPlanApiUrl `
                        -token $token

    # Check if the DDoS protection plan is enabled
    if ($null -eq $ddosResponse) {
        $Global:recommendations += Get-Recommendation -type "NoDDoSProtectionPlan" `
                                    -sddcName $sddcDetails.sddcName
    }
}

function Test-ERGateway-Connection-Utilization {
    param (
        [SecureString]$token,
        [string]$connectionId,
        [string]$sku
    )

    # Define the API URL to get utilization for the current gateway
    $utilizationApiUrl = [string]::Format(
        "https://management.azure.com{0}/providers/microsoft.insights/metrics?" +
        "metricnames=BitsInPerSecond,BitsOutPerSecond&" +
        "timespan={1}/{2}&" +
        "aggregation=maximum&" +
        "interval=P1D&" +
        "api-version=2023-10-01",
        $connectionId,
        (Get-Date (Get-Date).AddDays(-7) -Format 'yyyy-MM-ddTHH:mm:ssZ'),
        (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
    )


    # Make the API request to get utilization for the current gateway
    $utilizationResponse = Invoke-APIRequest `
                            -method "Get" `
                            -url $utilizationApiUrl `
                            -token $token

    # Check the utilization
    if ($utilizationResponse -and $utilizationResponse.value -and $utilizationResponse.value.Count -gt 0) {
        #Process each metric
        $data = $utilizationResponse.value | ForEach-Object {
            $_.timeseries[0].data 
        } | Sort-Object timestamp

        # Add the values in maximum column of $data for each timestamp
        $aggData = $data | Group-Object timestamp | ForEach-Object {
            [PSCustomObject]@{
                timestamp = $_.Name
                maximum = ($_.Group | Measure-Object maximum -Sum).Sum
            }
        }

        #Get the maximum utilization from the aggregated data
        $utilization = $aggData | Sort-Object maximum -Descending | Select-Object -First 1

        # Convert utilization from bits per second to Gbps
        $utilization = $utilization.maximum / 1000000000

        # Get the utilization based on the SKU
        $utilization /= switch ($sku) {
            ("Standard" -or "ErGw1Az") { 1; break }
            ("HighPerformance" -or "ErGw2Az") { 2; break }
            ("UltraPerformance" -or "ErGw3Az") { 10; break }
            default { 1 }
        }
        
        if ($utilization -lt 0.7) {
            $Global:recommendations += Get-Recommendation -type "LowUtilizationforERGateway" `
                                        -sddcName $sddcDetails.sddcName
        }
    }

}