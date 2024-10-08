function New-IfNotExist-IPSecSession-PolicyBased  {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$vpnServiceName,
        [string]$localEndpointPath,
        [string]$remoteGatewayIP,
        [string]$localAddress,
        [string]$remoteAddress,
        [string]$sessionName
    )

    if (Get-IPSecSession-PolicyBased -avsnsxTmanager $avsnsxTmanager `
                         -nsxtUserName $nsxtUserName `
                         -nsxtPassword $nsxtPassword `
                         -tier1GatewayName $tier1GatewayName `
                         -vpnServiceName $vpnServiceName `
                         -sessionName $sessionName) {
        Write-Host "IPSec Session with name '$sessionName' already exists."
    } else {
        try {
            Write-Host "IPSec Session '$sessionName' not found. Creating..."
            New-IPSecSession-PolicyBased -avsnsxTmanager $avsnsxTmanager `
                             -nsxtUserName $nsxtUserName `
                             -nsxtPassword $nsxtPassword `
                             -tier1GatewayName $tier1GatewayName `
                             -vpnServiceName $vpnServiceName `
                             -localEndpointPath $localEndpointPath `
                             -remoteGatewayIP $remoteGatewayIP `
                             -localAddress $localAddress `
                             -remoteAddress $remoteAddress `
                             -sessionName $sessionName
            write-host "IPSec Session '$sessionName' created successfully."
        } catch {
            Write-Error "Failed to create IPSec Session '$sessionName': $_"
        }
    }
}

function Get-IPSecSession-PolicyBased {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$vpnServiceName,
        [string]$sessionName
    )

    $ipsecSessionUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}" +
        "/ipsec-vpn-services/{1}/sessions",
        $tier1GatewayName,
        $vpnServiceName
    )

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $ipsecSessionUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword
        $ipsecSessions = $response.results | Where-Object { $_.display_name -eq $sessionName }
        if ($ipsecSessions) {
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Error "Failed to get IPSec Sessions: $_"
    }
}

function New-IPSecSession-PolicyBased {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$vpnServiceName,
        [string]$localEndpointPath,
        [string]$remoteGatewayIP,
        [string]$localAddress,
        [string]$remoteAddress,
        [string]$ikeProfileName = "nsx-default-l3vpn-ike-profile",
        [string]$ipsecProfileName = "nsx-default-l3vpn-tunnel-profile",
        [string]$dpdProfileName = "nsx-default-l3vpn-dpd-profile",
        [string]$sessionName
    )

    $ike_profile_path = Get-IKEProfilePath -avsnsxTmanager $avsnsxTmanager `
                                           -nsxtUserName $nsxtUserName `
                                           -nsxtPassword $nsxtPassword `
                                           -ikeProfileName $ikeProfileName

    $ipsec_profile_path = Get-IPSecProfilePath -avsnsxTmanager $avsnsxTmanager `
                                            -nsxtUserName $nsxtUserName `
                                            -nsxtPassword $nsxtPassword `
                                            -ipsecProfileName $ipsecProfileName

    $dpd_profile_path = Get-DPDProfilePath -avsnsxTmanager $avsnsxTmanager `
                                            -nsxtUserName $nsxtUserName `
                                            -nsxtPassword $nsxtPassword `
                                            -dpdProfileName $dpdProfileName

    $psk = New-PSK -length 8
    
    if (-not $ike_profile_path -or 
        -not $ipsec_profile_path -or
        -not $dpd_profile_path -or
        -not $psk) {
        Write-Error "Failed to get IKE Profile,IPSec, DPD Profile or PSK."
        return $null
    }                                           

    $ipsecSessionUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}" +
        "/ipsec-vpn-services/{1}/sessions/{2}",
        $tier1GatewayName,
        $vpnServiceName,
        $sessionName
    )

    $body = @{
        resource_type = "PolicyBasedIPSecVpnSession"
        enabled = $true
        display_name = $sessionName
        local_endpoint_path = $localEndpointPath
        peer_address = $remoteGatewayIP
        authentication_mode = "PSK"
        psk = $psk
        peer_id = $remoteGatewayIP
        ike_profile_path = $ike_profile_path
        tunnel_profile_path = $ipsec_profile_path
        dpd_profile_path = $dpd_profile_path
        connection_initiation_mode = "INITIATOR"
        rules = @(
            @{
                sources = @(
                    @{
                        subnet = $localAddress
                    }
                )
                destinations = @(
                    @{
                        subnet = $remoteNetwork
                    }
                )
                id = $remoteNetwork.split("/")[0]
            }
        )
        compliance_suite = "NONE"
        id = $sessionName
    }

    $jsonBody = $body | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-APIRequest -method "Put" `
                                      -url $ipsecSessionUrl `
                                      -body $jsonBody `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword
    } catch {
        Write-Error "Failed to create IPSec Session '$sessionName': $_"
    }
}

function Get-IKEProfilePath {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$ikeProfileName
    )

    $ikeProfileUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/search/aggregate?page_size=50" + 
            "&cursor=0&sort_by=display_name&sort_ascending=true"
    )

    $body = @{
        primary = @{
            resource_type = "IPSecVpnIkeProfile"
        }
        related = @(
            @{
                resource_type = "PolicyBasedIPSecVpnSession OR RouteBasedIPSecVpnSession"
                join_condition = "ike_profile_path:path"
                alias = "sessions"
                size = 0
            }
        )
    }

    try {
        $response = Invoke-APIRequest -method "Post" `
                                      -url $ikeProfileUrl `
                                      -body ($body | ConvertTo-Json) `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        $ikeProfilePath = $response.results |
            Where-Object { 
            $_.primary -and 
            $_.primary.display_name -and 
            $_.primary.display_name -eq $ikeProfileName 
            } |
            Select-Object -ExpandProperty primary |
            Select-Object -ExpandProperty path
            
        if ($ikeProfilePath) {
            return $ikeProfilePath
        } else {
            Write-Error "IKE Profile '$ikeProfileName' not found."
            return $null
        }
    } catch {
        Write-Error "Failed to get IKE Profile: $_"
        return $null
    }
}

function Get-IPSecProfilePath {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$ipsecProfileName
    )

    $ipsecProfileUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/search/aggregate?page_size=50" + 
            "&cursor=0&sort_by=display_name&sort_ascending=true"
    )

    $body = @{
        primary = @{
            resource_type = "IPSecVpnTunnelProfile"
        }
        related = @(
            @{
                resource_type = "PolicyBasedIPSecVpnSession OR RouteBasedIPSecVpnSession"
                join_condition = "tunnel_profile_path:path"
                alias = "sessions"
                size = 0
            }
        )
    }

    try {
        $response = Invoke-APIRequest -method "Post" `
                                      -url $ipsecProfileUrl `
                                      -body ($body | ConvertTo-Json) `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        $ipsecProfilePath = $response.results |
            Where-Object { 
            $_.primary -and 
            $_.primary.display_name -and 
            $_.primary.display_name -eq $ipsecProfileName 
            } |
            Select-Object -ExpandProperty primary |
            Select-Object -ExpandProperty path
            
        if ($ipsecProfilePath) {
            return $ipsecProfilePath
        } else {
            Write-Error "IPSec Profile '$ipsecProfileName' not found."
            return $null
        }
    } catch {
        Write-Error "Failed to get IPSec Profile: $_"
        return $null
    }
}

function Get-DPDProfilePath {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$dpdProfileName
    )

    $dpdProfileUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/search/aggregate?page_size=50" + 
            "&cursor=0&sort_by=display_name&sort_ascending=true"
    )

    $body = @{
        primary = @{
            resource_type = "IPSecVpnDpdProfile"
        }
        related = @(
            @{
                resource_type = "PolicyBasedIPSecVpnSession OR RouteBasedIPSecVpnSession"
                join_condition = "dpd_profile_path:path"
                alias = "sessions"
                size = 0
            }
        )
    }

    try {
        $response = Invoke-APIRequest -method "Post" `
                                      -url $dpdProfileUrl `
                                      -body ($body | ConvertTo-Json) `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        $dpdProfilePath = $response.results |
            Where-Object { 
            $_.primary -and 
            $_.primary.display_name -and 
            $_.primary.display_name -eq $dpdProfileName 
            } |
            Select-Object -ExpandProperty primary |
            Select-Object -ExpandProperty path
            
        if ($dpdProfilePath) {
            return $dpdProfilePath
        } else {
            Write-Error "DPD Profile '$dpdProfileName' not found."
            return $null
        }
    } catch {
        Write-Error "Failed to get DPD Profile: $_"
        return $null
    }
}

function New-PSK {
    param (
        [int]$length = 8
    )

    if ($length -lt 8) {
        throw "PSK length must be at least 8 characters."
    }

    # Define character sets
    $upperCase = 'A'..'Z'
    $lowerCase = 'a'..'z'
    $digits = '0'..'9'
    $specialChars = ('!'..'/' + ':'..'@' + '['..'`' + '{'..'~')

    # Ensure at least one character from each set
    $psk = @(
        $upperCase | Get-Random
        $lowerCase | Get-Random
        $digits | Get-Random
        $specialChars | Get-Random
    )

    # Fill the remaining characters
    $allChars = $upperCase + $lowerCase + $digits + $specialChars
    for ($i = $psk.Count; $i -lt $length; $i++) {
        $psk += $allChars | Get-Random
    }

    # Shuffle the result
    $psk = $psk | Sort-Object { Get-Random }

    # Convert to string and return
    return -join $psk
}