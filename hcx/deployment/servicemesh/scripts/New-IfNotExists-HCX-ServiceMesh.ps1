. .\Get-Interconnect-Capabilities.ps1
function New-IfNotExists-HCX-ServiceMesh {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [PSCustomObject]$hcxPairing,
        [PSCustomObject]$hcxComputeProfile
    )

    try {
        Write-Host "Checking for existing HCX Service Mesh and creating new if it does not exist..."
        # Check if the Service Mesh already exists
        $existingServiceMesh = Get-HCX-ServiceMesh `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        if ($existingServiceMesh -and $existingServiceMesh.items) {
            
            $matchingServiceMesh = $existingServiceMesh.items | Where-Object { $_.name -eq $serviceMeshName } | Select-Object -First 1
            if ($matchingServiceMesh) {
                Write-Host "HCX Service Mesh '$($matchingServiceMesh.name)' already exists."
                return $matchingServiceMesh
            }
        }

        # Create a new Service Mesh
        $newServiceMesh = New-HCX-ServiceMesh `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword `
            -hcxPairing $hcxPairing `
            -hcxComputeProfile $hcxComputeProfile

        if ($newServiceMesh -and $newServiceMesh.data -and $newServiceMesh.data.interconnectTaskId) {
            # Get Task details
            $taskDetails = Get-Interconnect-Task-Details -taskID $newServiceMesh.data.interconnectTaskId `
                -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword

            if ($taskDetails) {
                Write-Host "Service Mesh creation task started..."
            } else {
                Write-Host "Failed to retrieve task details for Service Mesh creation."
                return $null
            }

            # Check while status is "RUNNING" or "QUEUED". Break if it is "SUCCESS" or "FAILED"
            while ($taskDetails -and $taskDetails.status -eq "RUNNING" -or $taskDetails.status -eq "QUEUED") {
                Write-Host "Current Status: $($taskDetails.message), next check in 1 minute..."
                Start-Sleep -Seconds 60
                $taskDetails = Get-Interconnect-Task-Details -taskID $newServiceMesh.data.interconnectTaskId `
                    -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                    -hcxConnectorUserName $hcxConnectorUserName `
                    -hcxConnectorPassword $hcxConnectorPassword
            }
            
            if ($taskDetails -and $taskDetails.status -eq "SUCCESS") {
                $newServiceMesh = Get-HCX-ServiceMesh -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword

                Write-Host "New HCX Service Mesh '$($newServiceMesh.items[0].name)' created successfully."
                return $newServiceMesh

            } elseif ($taskDetails -and $taskDetails.status -eq "FAILED") {
                Write-Host "Service Mesh creation failed: $($taskDetails.errorMessage)"
                return $null
            }
            return $newServiceMesh
        } else {
            Write-Host "Failed to create HCX Service Mesh."
            return $null
        }
    }
    catch {
        Write-Host "Error processing HCX Service Mesh: $_"
    }
}

function Get-HCX-ServiceMesh {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/serviceMesh",
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
        if ($response -and $response.items.Count -gt 0) {
            return $response
        } else {
            return $null
        }
    }
    catch {
        Write-Host "Error retrieving HCX Service Mesh: $_"
    }
}

function New-HCX-ServiceMesh {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [PSCustomObject]$hcxPairing,
        [PSCustomObject]$hcxComputeProfile
    )

    try {
        # Get Pre-requisite data
        $preReqData = Get-HCX-ServiceMesh-PreReqData `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword `
            -hcxPairing $hcxPairing `
            -hcxComputeProfile $hcxComputeProfile

        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/serviceMesh",
            $hcxConnectorServiceUrl
        )

        # Define the body
        $body = @{
            name = $serviceMeshName
            computeProfiles = @(
                @{
                    endpointId = $preReqData.sourceEndpointId
                    computeProfileId = $preReqData.sourceComputeProfileID
                    overriddenUplink = $true
                    networks = @(
                        @{
                            id = $preReqData.sourceUplinkNetworkID
                            tags = @("uplink")
                        }
                    )
                }
                @{
                    endpointId = $preReqData.remoteEndpointId
                    computeProfileId = $preReqData.remoteComputeProfileId
                    overriddenUplink = $true
                    networks = @(
                        @{
                            id = $preReqData.remoteUplinkNetworkID
                            tags = @("uplink")
                        }
                    )
                }
            )
            services = @(
                @{ name = "INTERCONNECT" }
                @{ name = "VMOTION" }
                @{ name = "BULK_MIGRATION" }
                @{ name = "RAV" }
                @{ name = "NETWORK_EXTENSION" }
                @{ name = "DISASTER_RECOVERY" }
            )
            wanoptConfig = @{
                uplinkMaxBandwidth = 10000000
            }
            trafficEnggCfg = @{
                isAppPathResiliencyEnabled = $false
                isTcpFlowConditioningEnabled = $false
                isEncryptionlessTunnelEnabledForMigration = $false
                isEncryptionlessTunnelEnabledForNE = $false
                groEnabled = $false
            }
            switchPairCount = @(
                @{
                    switches = @(
                        @{
                            cmpId = $preReqData.sourceSwitchCmpId
                            id = $preReqData.sourceSwitchId
                            type = $preReqData.sourceSwitchType
                        }
                        @{
                            cmpId = $preReqData.remoteSwitchCmpId
                            id = $preReqData.remoteSwitchId
                            type = $preReqData.remoteSwitchType
                        }
                    )
                    l2cApplianceCount = 1
                }
            )
        }

        $bodyJson = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-API -method "POST" `
            -url $apiUrl `
            -Body $bodyJson `
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
        Write-Host "Error creating HCX Service Mesh: $_"
    }
}

function Get-HCX-ServiceMesh-PreReqData {
    param(
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [PSCustomObject]$hcxPairing,
        [PSCustomObject]$hcxComputeProfile
    )
    try {

        # Get Remote Endpoint ID from HCX Pairing
        if ($hcxPairing) {
            $remoteEndpointId = $hcxPairing.endpointId
        }

        # Get Compute Profile ID for remote endpoint
        if ($remoteEndpointId) {
            $remoteComputeProfile = Get-HCX-ComputeProfile-By-Endpoint -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword `
                -endpointId $remoteEndpointId
        }

        if ($remoteComputeProfile) {
            # Get all items from the remote compute profile
            $remoteComputeProfileItems = $remoteComputeProfile.items

            # Find the computeProfileID from $remoteComputeProfileItems's first item
            if ($remoteComputeProfileItems -and $remoteComputeProfileItems.Count -gt 0) {
                $remoteComputeProfileId = $remoteComputeProfileItems[0].computeProfileId

                #Find the value of id as string from network array where any items has value "uplink" in tags array
                $remoteUplinkNetwork = $remoteComputeProfileItems[0].networks | Where-Object {
                    $_.tags -contains "uplink"
                }

                $remoteUplinkNetworkID = $remoteUplinkNetwork.id


                # Extract cmpID, id and type from "switches" array where type is "OVERLAY_STANDARD" in the first item of remoteComputeProfileItems
                $remoteSwitches = $remoteComputeProfileItems[0].switches | Where-Object {
                    $_.type -eq "OVERLAY_STANDARD"
                }
                if ($remoteSwitches -and $remoteSwitches.Count -gt 0) {
                    $remoteSwitch = $remoteSwitches[0]
                    $remoteSwitchCmpId = $remoteSwitch.cmpId
                    $remoteSwitchId = $remoteSwitch.id
                    $remoteSwitchType = $remoteSwitch.type
                }
            }
        }

        # Get Interconnect Capabilities To find source endpoint ID
        $interconnectCapabilities = Get-Interconnect-Capabilities `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        if ($interconnectCapabilities) {
            # Expand $interconnectCapabilities Items to get object array. Expand each array to get endpoints array. Within that, filter out the endpoint ID which is not $remoteEndpointId.
            $allEndpoints = $interconnectCapabilities.items | ForEach-Object { 
            if ($_.endpoints) { $_.endpoints } 
            }
            $filteredEndpoints = $allEndpoints | Where-Object { 
                $_.endpointId -and $_.endpointId -ne $remoteEndpointId 
            }
            if ($filteredEndpoints) {
                $sourceEndpointId = $filteredEndpoints[0].endpointId
            }
        }

        # Get Source Compute Profile ID for source endpoint from HCX Compute Profile
        if ($sourceEndpointId) {

            # Get the source compute profile ID
            $sourceComputeProfileID = $hcxComputeProfile.computeProfileId

            # Use $useMgmtForUplinkInServiceMesh to determine if we should use management network for uplink
            if ($useMgmtForUplinkInServiceMesh) {
                # Get the source Management network ID from the source compute profile
                $sourceMgmtNetwork = $hcxComputeProfile.networks | Where-Object {
                    $_.tags -contains "management"
                }
                $sourceUplinkNetworkID = $sourceMgmtNetwork.id
            } else {
                # Get the source uplink network ID from the source compute profile
                $sourceUplinkNetwork = $hcxComputeProfile.networks | Where-Object {
                    $_.tags -contains "uplink"
                }
                $sourceUplinkNetworkID = $sourceUplinkNetwork.id     
            }

            # Get the source switches
            $sourceSwitches = $hcxComputeProfile.switches | Where-Object {
                    $_.type -eq "VmwareDistributedVirtualSwitch"
            }

            if ($sourceSwitches -and $sourceSwitches.Count -gt 0) {
                $sourceSwitch = $sourceSwitches[0]
                $sourceSwitchCmpId = $sourceSwitch.cmpId
                $sourceSwitchId = $sourceSwitch.id
                $sourceSwitchType = $sourceSwitch.type
            }
        }

        $retValue = @{
            remoteEndpointId = $remoteEndpointId
            remoteComputeProfileId = $remoteComputeProfileId
            remoteUplinkNetworkID = $remoteUplinkNetworkID
            remoteSwitchCmpId = $remoteSwitchCmpId
            remoteSwitchId = $remoteSwitchId
            remoteSwitchType = $remoteSwitchType
            sourceEndpointId = $sourceEndpointId
            sourceComputeProfileID = $sourceComputeProfileID
            sourceUplinkNetworkID = $sourceUplinkNetworkID
            sourceSwitchCmpId = $sourceSwitchCmpId
            sourceSwitchId = $sourceSwitchId
            sourceSwitchType = $sourceSwitchType
        }
        
        return $retValue
    }
    catch {
        Write-Host "Error retrieving HCX Service Mesh prerequisites: $_"
    }
    
}