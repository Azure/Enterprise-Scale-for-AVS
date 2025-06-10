. .\Get-SegmentID.ps1
. .\Get-ResourcePoolID.ps1

function Show-SimpleProgress {
    param (
        [string]$Message = "Processing"
    )
    
    Write-Host "$Message..." -NoNewline
}

function Hide-SimpleProgress {
    param (
        [string]$Message = "Processing"
    )
    
    Write-Host "Done!"
}

function New-IfNotExist-VM-From-OVA {
   param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryItemID,
        [string]$segmentName,
        [string]$applianceVMName,
        [string]$applianceVMIP,
        [string]$applianceVMGatewayIP
    )
    
    try {
        
        # Check if the VM already exists
        $existingVM = Get-VM -vCenter $vCenter `
                                  -vCenterUserName $vCenterUserName `
                                  -vCenterPassword $vCenterPassword `
                                  -applianceVMName $applianceVMName
        
        if ($existingVM) {
            Write-Host "VM '$applianceVMName' already exists. Skipping creation."
            return $true
        }

        # Create a new VM from the OVA
        $newVMCreationStatus = New-VM-From-OVA -vCenter $vCenter `
                        -vCenterUserName $vCenterUserName `
                        -vCenterPassword $vCenterPassword `
                        -contentLibraryItemID $contentLibraryItemID `
                        -segmentName $segmentName `
                        -applianceVMName $applianceVMName `
                        -applianceVMIP $applianceVMIP `
                        -applianceVMGatewayIP $applianceVMGatewayIP

        return $newVMCreationStatus
    }
    catch {
        Write-Error "Failed to get OVF Properties: $_"
    }
}
function New-VM-From-OVA {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryItemID,
        [string]$segmentName,
        [string]$applianceVMName,
        [string]$applianceVMIP,
        [string]$applianceVMGatewayIP
    )
        try {

            #Get the Segment ID
            $segmentID = Get-SegmentID -vCenter $vCenter `
                              -vCenterUserName $vCenterUserName `
                              -vCenterPassword $vCenterPassword `
                              -segmentName $segmentName

            if (-not $segmentID) {
                Write-Error "Segment '$segmentName' not found. Please ensure it exists in the vCenter."
                return $false
            }                              

            # Get the Resource Pool ID
            $resourcePoolID = Get-ResourcePoolID -vCenter $vCenter `
                                                  -vCenterUserName $vCenterUserName `
                                                  -vCenterPassword $vCenterPassword
            
            # Create API Endpoint
            $ovfUrl = [string]::Format(
                "{0}" +
                "api/vcenter/ovf/library-item/{1}?action=deploy",
                $vCenter,
                $contentLibraryItemID
            )

            # Define the body
            $body = @{
                target = @{
                    resource_pool_id = $resourcePoolID
                }
                deployment_spec = @{
                    accept_all_EULA = "true"
                    name = $applianceVMName
                    network_mappings = @{
                        VSMgmt = $segmentID
                    }
                    additional_parameters = @(
                        @{
                            type = "IPAllocationParams"
                            _type = "com.vmware.vcenter.ovf.IPAllocationParams"
                            supportedIpAllocationPolicy = @(
                                @{
                                    name = "STATIC_MANUAL"
                                }
                            )
                            ipAllocationPolicy =  @{
                                    name = "STATIC_MANUAL"
                            }
                            supportedIpProtocol = @(
                                @{
                                    name = "IPV4"
                                    unknown = $false
                                    enumValue = "IPV4"
                                    localizedName = "IPv4"
                                }
                            )
                            ipProtocol = @{
                                    name = "IPV4"
                                    unknown = $false
                                    enumValue = "IPV4"
                                    localizedName = "IPv4"
                            }   
                        },
                        @{
                            type = "PropertyParams"
                            _type = "com.vmware.vcenter.ovf.PropertyParams"
                            properties = @(
                                @{
                                    classId = ""
                                    id = "mgr_cli_passwd"
                                    instanceId = ""
                                    category = "Passwords"
                                    uiOptional = $false
                                    label = "CLI `"`admin`"` User Password"
                                    description = "The password for default CLI user for this VM."
                                    type = "password"
                                    value = $vCenterPassword | ConvertFrom-SecureString -AsPlainText
                                },
                                @{
                                    classId = ""
                                    id = "mgr_root_passwd"
                                    instanceId = ""
                                    category = "Passwords"
                                    uiOptional = $false
                                    label = "root Password"
                                    description = "The password for root user."
                                    type = "password"
                                    value = $vCenterPassword | ConvertFrom-SecureString -AsPlainText
                                },
                                @{
                                    classId = ""
                                    id = "hostname"
                                    instanceId = ""
                                    category = "Network properties"
                                    uiOptional = $false
                                    label = "Hostname"
                                    description = "The hostname for this VM."
                                    type = "string"
                                    value = $applianceVMName
                                },
                                @{
                                    classId = ""
                                    id = "mgr_ip_0"
                                    instanceId = ""
                                    category = "Network properties"
                                    uiOptional = $false
                                    label = "Network 1 IPv4 Address"
                                    description = "The IPv4 Address for this interface. Leave this empty for DHCP base IP assignment."
                                    type = "string"
                                    value = $applianceVMIP
                                },
                                @{
                                    classId = ""
                                    id = "mgr_prefix_ip_0"
                                    instanceId = ""
                                    category = "Network properties"
                                    uiOptional = $false
                                    label = "Network 1 IPv4 Prefix Length"
                                    description = "The IPv4 prefix Length for this interface."
                                    type = "string(..2)"
                                    value = "27"
                                },
                                @{
                                    classId = ""
                                    id = "mgr_gateway_0"
                                    instanceId = ""
                                    category = "Network properties"
                                    uiOptional = $false
                                    label = "Default IPv4 Gateway"
                                    description = "The default gateway for this VM."
                                    type = "string"
                                    value = $applianceVMGatewayIP
                                },
                                @{
                                    classId = ""
                                    id = "mgr_static_network_1"
                                    instanceId = ""
                                    category = "Static Routes"
                                    uiOptional = $false
                                    label = "Static Route 1: Network"
                                    description = "Static Route 1: Network"
                                    type = "string"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_static_network_prefix_1"
                                    instanceId = ""
                                    category = "Static Routes"
                                    uiOptional = $false
                                    label = "Static Route 1: Prefix Length"
                                    description = "Static Route 1: Prefix Length"
                                    type = "string(..2)"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_static_gateway_ip_1"
                                    instanceId = ""
                                    category = "Static Routes"
                                    uiOptional = $false
                                    label = "Static Route 1: Gateway IP Address"
                                    description = "Static Route 1: Gateway IP Address"
                                    type = "string"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_static_network_2"
                                    instanceId = ""
                                    category = "Static Routes"
                                    uiOptional = $false
                                    label = "Static Route 2: Network"
                                    description = "Static Route 2: Network"
                                    type = "string"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_static_network_prefix_2"
                                    instanceId = ""
                                    category = "Static Routes"
                                    uiOptional = $false
                                    label = "Static Route 2: Prefix Length"
                                    description = "Static Route 2: Prefix Length"
                                    type = "string(..2)"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_static_gateway_ip_2"
                                    instanceId = ""
                                    category = "Static Routes"
                                    uiOptional = $false
                                    label = "Static Route 2: Gateway IP Address"
                                    description = "Static Route 2: Gateway IP Address"
                                    type = "string"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_dns_list"
                                    instanceId = ""
                                    category = "DNS"
                                    uiOptional = $false
                                    label = "DNS Server list"
                                    description = "The DNS server list(space separated) for this VM."
                                    type = "string"
                                    value = "1.1.1.1"
                                },
                                @{
                                    classId = ""
                                    id = "mgr_domain_search_list"
                                    instanceId = ""
                                    category = "DNS"
                                    uiOptional = $false
                                    label = "Domain Search List"
                                    description = "The domain Search list(space separated) for this VM."
                                    type = "string"
                                    value = ""
                                },
                                @{
                                    classId = ""
                                    id = "mgr_ntp_list"
                                    instanceId = ""
                                    category = "Services Configuration"
                                    uiOptional = $false
                                    label = "NTP Server List"
                                    description = "The NTP server list(space separated) for this VM."
                                    type = "string"
                                    value = ""
                                }
                            )
                        }
                    )
                }
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
              # Make the request
            Show-SimpleProgress -Message "Creating HCX Appliance VM from OVA"
            $response = Invoke-APIRequest -method "Post" `
                                        -url $ovfUrl `
                                        -body $jsonBody `
                                        -vCenter $vCenter `
                                        -vCenterUserName $vCenterUserName `
                                        -vCenterPassword $vCenterPassword
            Hide-SimpleProgress -Message "Creating HCX Appliance VM from OVA"

            if ($response -and $response.resource_id -and $response.resource_id.id) {
                Write-Host "HCX Appliance VM deployment completed successfully."
                # Start the VM                        
                Start-VM -vCenter $vCenter -vCenterUserName $vCenterUserName `
                    -vCenterPassword $vCenterPassword `
                    -vmID $response.resource_id.id

                Return $true
            }
        }
        catch {
            Write-Error "Failed to create VM from OVF: $_"
        }
}

function Get-OVF-Properties {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryItemID,
        [string]$segmentName
    )
        try {      
            # Create API Endpoint
            $ovfUrl = [string]::Format(
                "{0}" +
                "api/vcenter/ovf/library-item/{1}?action=filter",
                $vCenter,
                $contentLibraryItemID
            )

            # Define the body
            $body = @{
                target = @{
                    resource_pool_id = "resgroup-9"
                }
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            
            # Make the request
            $response = Invoke-APIRequest -method "Post" `
                                        -url $ovfUrl `
                                        -body $jsonBody `
                                        -vCenter $vCenter `
                                        -vCenterUserName $vCenterUserName `
                                        -vCenterPassword $vCenterPassword
            
            if ($response) {
                 
            }
        }
        catch {
            Write-Error "Failed to get OVF Properties: $_"
        }
}

function Start-VM {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$vmID
    )
    
    # Create API Endpoint to power on the VM
    $powerOnUrl = [string]::Format(
        "{0}" +
        "api/vcenter/vm/{1}/power?action=start",
        $vCenter,
        $vmID
    )
    
    # Make the request to power on the VM
    Invoke-APIRequest -method "Post" `
                                  -url $powerOnUrl `
                                  -vCenter $vCenter `
                                  -vCenterUserName $vCenterUserName `
                                  -vCenterPassword $vCenterPassword
}

function Get-VM {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$applianceVMName
    )
    
    # Create API Endpoint to filter the VM based on name
    $vmUrl = [string]::Format(
        "{0}" +
        "api/vcenter/vm",
        $vCenter,
        $applianceVMName
    )
    
    # Make the request
    $response = Invoke-APIRequest -method "Get" `
                                      -url $vmUrl `
                                      -vCenter $vCenter `
                                      -vCenterUserName $vCenterUserName `
                                      -vCenterPassword $vCenterPassword
    
    # Process the response to find the VM
    if ($response) {
        return $response.Where({ $_.name -eq $applianceVMName })
    }
    
    return $null
}