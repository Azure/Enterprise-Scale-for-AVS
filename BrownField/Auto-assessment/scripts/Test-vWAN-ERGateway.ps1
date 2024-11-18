function Test-vWAN-ERGateway {
    param(
        [SecureString]$token,
        [PSCustomObject]$sddc,
        [System.Object[]]$allvWANgateways        
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
                
                foreach ($vWANgateway in $allvWANgateways) {
                    Test-vWAN-ERGateway-Connection -vWANgateway $vWANgateway `
                                        -expressRouteId $sddc.Properties.circuit.expressRouteID `
                                        -token $token
                    
                }
                
            }
        }   
    }
    catch {
        Write-Error "ER Gateway Test failed: $_"
    }
}

function Test-vWAN-ERGateway-Connection {
    param (
        [PSCustomObject]$vWANgateway,
        [string]$expressRouteId,
        [SecureString]$token
    )

    # Define the API URL to get connections for the current gateway
    $connectionsApiUrl = "https://management.azure.com$($vWANgateway.id)/expressRouteConnections?api-version=2024-03-01"

    # Make the API request to get connections for the current gateway
    $authResponse = Invoke-APIRequest `
                        -method "Get" `
                        -url $connectionsApiUrl `
                        -token $token

    # Check if the peer ID is present in the connections
    if ($authResponse.value | `
            Where-Object `
            { 
                $_.properties.expressRouteCircuitPeering.id.Contains($expressRouteId) 
            }
        ) 
    {
        $Global:recommendations += Get-Recommendation -type "ZoneRedundantvWANGateway" -sddcName $sddcDetails.sddcName
        $Global:recommendations += Get-Recommendation -type "NonFastPathvWANGateway" -sddcName $sddcDetails.sddcName

        # Test the utilization of the vWAN ER Gateway
        Test-vWAN-ERGateway-Utilization -token $token `
                -vWANgateway $vWANgateway
    }
}

function Test-vWAN-ERGateway-Utilization {
    param (
        [SecureString]$token,
        [PSCustomObject]$vWANgateway
    )

    # Define the API URL to get utilization for the current gateway
    $utilizationApiUrl = [string]::Format(
        "https://management.azure.com{0}/providers/microsoft.insights/metrics?" +
        "metricnames=ErGatewayConnectionBitsInPerSecond,ErGatewayConnectionBitsOutPerSecond&" +
        "timespan={1}/{2}&" +
        "aggregation=maximum&" +
        "interval=P1D&" +
        "api-version=2023-10-01",
        $vWANgateway.id,
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

        # Convert utilization from bits per second to Mbps
        $utilization = $utilization.maximum / 1000000

        # Get the utilization based on the number of instances
        Get-Utilization-BasedOnERGatewayInstances -vWANgateway $vWANgateway `
                        -currentUtilization $utilization        
        
    }
}

function Get-Utilization-BasedOnERGatewayInstances {
    param (
        [PSCustomObject]$vWANgateway,
        [double]$currentUtilization
    )

    # Get vWAN Scale Bounds
    $instances = $vWANgateway.properties.autoScaleConfiguration.bounds.min

    # Calculate the utilization based on the number of instances
    $utilization = switch ($instances) {
        1 { $currentUtilization / 2000; break }
        2 { $currentUtilization / 4000; break }
        3 { $currentUtilization / 6000; break }
        4 { $currentUtilization / 8000; break }
        5 { $currentUtilization / 10000; break }
        6 { $currentUtilization / 12000; break }
        7 { $currentUtilization / 14000; break }
        8 { $currentUtilization / 16000; break }
        9 { $currentUtilization / 18000; break }
        10 { $currentUtilization / 20000; break }
    }

    if ($utilization -lt 0.7) {
        $Global:recommendations += Get-Recommendation -type "LowUtilizationforvWANERGateway" `
                                    -sddcName $sddcDetails.sddcName
    }
}