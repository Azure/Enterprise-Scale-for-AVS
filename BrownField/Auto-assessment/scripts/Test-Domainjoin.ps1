function Test-Domainjoin {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc,
        [PSCredential] $avsVMcredentials
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get the NSX-T credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Get encryption policies
        $encryptionPolicies = Get-Encryption-Storage-Policies -sddc $sddcDetails `
                            -credentials $credentials
        
        # Get VMs
        $vms = Get-VMs -sddc $sddcDetails -credentials $credentials

        # Process $vms
        if ($vms -and $vms.value -and $vms.value.count -gt 0) {
            # Get SAMLTOKEN
            #$samlToken = Get-SAMLToken-ForGuestVMInfo -vCenterUrl $sddcDetails.vCenterUrl `
            #-vCenterUsername $credentials.vCenterUsername `
            #-vCenterPassword $credentials.vCenterPassword
            foreach ($vm in $vms.value) {
                $loopCounter++

                if ($loopCounter -eq 10) {
                    break
                }

                # Get VM Details
                $vmDetails = Get-VM-Details -sddc $sddcDetails `
                            -credentials $credentials `
                            -vmID $vm.vm

                # Process the response if the VM is Windows
                if ($vmDetails.value.guest_OS -match "Windows") {
                    
                    # Check only 3 VMs
                    $counter++
                    if ($counter -eq 3) {
                        break
                    }

                    # Test VM Encryption
                    Test-VM-Encryption -sddcDetails $sddcDetails `
                                -credentials $credentials `
                                -encryptionPolicies $encryptionPolicies `
                                -vmID $vm.vm

                    # Get VM Environment Variables For DNS check
                    $vmGuestInfo = Get-VM-EnvironmentVars -sddc $sddcDetails `
                                    -credentials $credentials `
                                    -vmID $vm.vm
                    
                    # Process the response
                    if ($vmGuestInfo) {

                        # Determine if the VM is joined to a domain or workgroup
                        if ($vmGuestInfo.USERDNSDOMAIN) {
                            #Write-Output "$($envVars.COMPUTERNAME) is domain joined to Active Directory domain $($envVars.USERDNSDOMAIN)"
                        } elseif ($vmGuestInfo.USERDOMAIN -ne $vmGuestInfo.COMPUTERNAME) {
                            #Write-Output "$($envVars.COMPUTERNAME) is domain joined to $($envVars.USERDOMAIN)"
                        } else {
                            $recommendationType = "NoDomainJoin"
                        }
                        
                    }
                }
            }

            # Add the recommendation
            if (![string]::IsNullOrEmpty($recommendationType)) {
                $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                    -sddcName $sddcDetails.sddcName
            }
        }
    }
    catch {
        Write-Host "Domainjoin Test failed: $_"
    }
}

function Get-SAMLToken-ForGuestVMInfo {
    param (
        [string]$vCenterUrl,
        [string]$vCenterUsername,
        [SecureString]$vCenterPassword
    )

    try {
        $ssoUrl = [string]::Format(
                    "{0}" +
                    "sts/STSService/vsphere.local",
                    $vCenterUrl
        )

        $currentTime = [System.DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        $expiryTime = ([System.DateTime]::UtcNow.AddHours(1)).ToString("yyyy-MM-ddTHH:mm:ssZ")

        $plainvCenterPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($vCenterPassword))

$ssoBody = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:wst="http://docs.oasis-open.org/ws-sx/ws-trust/200512" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  <soapenv:Header>
    <wsa:Action>http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</wsa:Action>
    <wsa:To>$ssoUrl</wsa:To>
    <wsse:Security>
      <wsu:Timestamp wsu:Id="Timestamp-1">
        <wsu:Created>$currentTime</wsu:Created>
        <wsu:Expires>$expiryTime</wsu:Expires>
      </wsu:Timestamp>
      <wsse:UsernameToken>
        <wsse:Username>$vCenterUsername</wsse:Username>
        <wsse:Password>$plainvCenterPassword</wsse:Password>
      </wsse:UsernameToken>
    </wsse:Security>
  </soapenv:Header>
  <soapenv:Body>
    <wst:RequestSecurityToken>
      <wst:TokenType>urn:oasis:names:tc:SAML:2.0:assertion</wst:TokenType>
      <wst:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</wst:RequestType>
    </wst:RequestSecurityToken>
  </soapenv:Body>
</soapenv:Envelope>
"@

        $response = Invoke-WebRequest -Uri $ssoUrl `
                    -Method Post -ContentType "text/xml" `
                    -Headers @{ "SOAPAction" = "http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue" } `
                    -Body $ssoBody

        # Convert the response content to an XML object
        $xmlResponse = [xml]$response.Content                    

        $assertionNode = Select-Xml -Xml $xmlResponse -Namespace @{ "saml2" = "urn:oasis:names:tc:SAML:2.0:assertion" } `
                            -XPath "//saml2:Assertion"
                            
        $samlToken = $assertionNode.Node.OuterXml

        return $samlToken
    }
    catch {
        Write-Host "Getting SAML in Domainjoin Test failed: $_"
    }
}

function Test-VM-Encryption {
    param (
        [PSCustomObject]$sddcDetails,
        [PSCustomObject]$credentials,
        [object[]]$encryptionPolicies,
        [string]$vmID
    )

    try {

         # Construct API URL for VM Guest Info
         $apiUrl = [string]::Format(
            "{0}" +
            "api/vcenter/vm/{1}/storage/policy",
            $sddcDetails.vCenterUrl,
            $vm.vm
        )

        # Invoke the API call to check the VM's encryption status
        $response = Invoke-APIRequest -method "GET" `
                    -url $apiUrl `
                    -avsVcenter $sddcDetails.vCenterUrl `
                    -avsvCenterUserName $credentials.vCenterUsername `
                    -avsvCenterPassword $credentials.vCenterPassword

        # Check the encryption status
        if ($response) {
            $isEncrypted = $encryptionPolicies | Where-Object {
                $_.policy -eq $response.vm_home
            }

            if (-not $isEncrypted) {
            $recommendationType = "NoVMEncryption"
            }
        }
        
        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Host "VM Encryption Test failed: $_"
    }

}

function Get-Encryption-Storage-Policies {
    param (
        [PSCustomObject]$sddc,
        [PSCustomObject]$credentials
    )

    try {
        # Get all storage policies
        $storageapiUrl = [string]::Format(
            "{0}" +
            "api/vcenter/storage/policies",
            $sddc.vCenterUrl
        )

        # Make API call
        $response = Invoke-APIRequest -method "GET" `
                    -url $storageapiUrl `
                    -avsVcenter $sddc.vCenterUrl `
                    -avsvCenterUserName $credentials.vCenterUsername `
                    -avsvCenterPassword $credentials.vCenterPassword

        # Check the response
        if ($response) {
            $encryptionPolicies = $response | Where-Object {
                $_.name -match "encryption" -or $_.description -match "encryption"
            }

            return $encryptionPolicies
        }
    }
    catch {
        Write-Host "Getting storage policies failed: $_"
    }
}

function Get-VMs {
    param (
        [PSCustomObject]$sddc,
        [PSCustomObject]$credentials
    )

    try {
        # Define the API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "rest/vcenter/vm?filter.power_states=POWERED_ON&filter.names=%5B%22%5E%28%3F%21TNT%29.%2A%22%5D",
            $sddc.vCenterUrl
        )
        
        # Make the request
        $response = Invoke-APIRequest -method "GET" `
            -url $apiUrl `
            -avsVcenter $sddc.vCenterUrl `
            -avsvCenterUserName $credentials.vCenterUsername `
            -avsvCenterPassword $credentials.vCenterPassword

            return $response
    }
    catch {
        Write-Host "Getting VMs failed: $_"
    }
}

function Get-VM-Details {
    param (
        [PSCustomObject]$sddc,
        [PSCustomObject]$credentials,
        [string]$vmID
    )

    try {
        # Construct the API URL
        $vmApiUrl = [string]::Format(
            "{0}" +
            "rest/vcenter/vm/{1}",
            $sddcDetails.vCenterUrl,
            $vmID
        )

        # Make the request
        $response = Invoke-APIRequest -method "GET" `
            -url $vmApiUrl `
            -avsVcenter $sddcDetails.vCenterUrl `
            -avsvCenterUserName $credentials.vCenterUsername `
            -avsvCenterPassword $credentials.vCenterPassword

        return $response
    }
    catch {
        Write-Host "Getting VM details failed: $_"
    }
}

function Get-VM-EnvironmentVars {

    param (
        [PSCustomObject]$sddc,
        [PSCustomObject]$credentials,
        [string]$vmID
    )

    try {
        # Construct API URL for VM Guest Info
        $vmGuestInfoApiUrl = [string]::Format(
            "{0}" +
            "api/vcenter/vm/{1}/guest/environment?action=list",
            $sddc.vCenterUrl,
            $vmID
        )

        $body = @{
            credentials = @{
                interactive_session = $false
                type = "USERNAME_PASSWORD"
                user_name = $avsVMcredentials.UserName
                password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($avsVMcredentials.Password))
            }
            names = @(
            )
        }

        $body2 = @{
            credentials = @{
                interactive_session = $false
                type = "SAML_BEARER_TOKEN"
                saml_token = $samlToken
            }
            names = @(
            )
        }

        $body = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-APIRequest -method "POST" `
            -body $body `
            -url $vmGuestInfoApiUrl `
            -avsVcenter $sddcDetails.vCenterUrl `
            -avsvCenterUserName $credentials.vCenterUsername `
            -avsvCenterPassword $credentials.vCenterPassword

        return $response
    }
    catch {
        Write-Host "Getting VM Environment variables failed: $_"
    }
}