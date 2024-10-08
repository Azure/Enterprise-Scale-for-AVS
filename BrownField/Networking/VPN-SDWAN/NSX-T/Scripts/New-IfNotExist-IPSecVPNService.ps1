function New-IfNotExist-IPSecVPNService {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$ipSecVpnServiceName
    )

    if (Get-IPSecVPNService `
            -avsnsxTmanager $avsnsxTmanager `
            -nsxtUserName $nsxtUserName `
            -nsxtPassword $nsxtPassword `
            -tier1GatewayName $tier1GatewayName `
            -ipSecVpnServiceName $ipSecVpnServiceName) {
        Write-Host "IPSec VPN Service '$ipSecVpnServiceName' already exists."
    } else {
        try {
            Write-Host "IPSec VPN Service '$ipSecVpnServiceName' not found. Creating..."
            New-IPSecVPNService -avsnsxTmanager $avsnsxTmanager `
                                -nsxtUserName $nsxtUserName `
                                -nsxtPassword $nsxtPassword `
                                -tier1GatewayName $tier1GatewayName `
                                -ipSecVpnServiceName $ipSecVpnServiceName
        } catch {
            Write-Error "Failed to create IPSec VPN Service '$ipSecVpnServiceName': $_"
        }
    }


}

function  Get-IPSecVPNService {
    param (
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$ipSecVpnServiceName
    )
    
    $ipSecVpnServiceUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}/ipsec-vpn-services",
        $tier1GatewayName
        )
    

    try {
    $response = Invoke-APIRequest -method "Get" `
                -url $ipSecVpnServiceUrl `
                -avsnsxtUrl $avsnsxTmanager `
                -avsnsxtUserName $nsxtUserName `
                -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or 
                    $null -eq $response.results -or 
                    $response.result_count -lt 1) {
            return $false
        }
        foreach ($ipSecVpnService in $response.results) {
            if ($ipSecVpnService.display_name -eq $ipSecVpnServiceName -and
                $ipSecVpnService.parent_path.split("/")[-1] -eq $tier1GatewayName) {
                return $true
            }
        }
    }
    catch {
        Write-Error "Failed to get NSX-T Transport Zone Path: $_"
        return $false
    }
}

function New-IPSecVPNService {
    param (
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$ipSecVpnServiceName
    )
    
    $ipSecVpnServiceUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}/ipsec-vpn-services/{1}",
        $tier1GatewayName,
        $ipSecVpnServiceName
        )

    $body = @{
        resource_type = "IPSecVpnService"
        display_name = $ipSecVpnServiceName
        id = $ipSecVpnServiceName
        enabled = $true 
        ha_sync = $true
        ike_log_level = "INFO"
    }

    try {
        $response = Invoke-APIRequest -method "Put" `
                                      -url $ipSecVpnServiceUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword `
                                      -body ($body | ConvertTo-Json -Depth 10)

        if ($null -eq $response) {
            Write-Error "Failed to create IPSec VPN Service"
        } else {
            Write-Host "Created IPSec VPN Service: '$ipSecVpnServiceName'"
        }
    }
    catch {
        Write-Error "Failed to create IPSec VPN Service: $_"
    }
}