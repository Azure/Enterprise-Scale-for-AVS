function Test-External-Identity-Source {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Determine the recommendation type
        if ($sddc -and $sddc.properties) {
            $identitySources = $sddc.Properties.identitySources
            $sddcName = $sddc.name

            if ($identitySources.Count -eq 0) {
                $Global:recommendations += Get-Recommendation -type "NoExternalIdentitySource" -sddcName $sddcName
            } else {
                $domain = $identitySources[0].domain
                $primaryServerValue = $identitySources[0].primaryServer

                $Global:recommendations += Get-Recommendation -type "ExternalIdentitySource" `
                                            -sddcName $sddcName `
                                            -externalIdentitySource $domain

                if ($primaryServerValue) {
                    $recommendationType = if ($primaryServerValue -match '^ldap://') {
                        "LDAPIdentitySource"
                    } elseif ($primaryServerValue -match '^ldaps://') {
                        "LDAPSIdentitySource"
                    }

                    if ($recommendationType) {
                        $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                        -sddcName $sddcName `
                                                        -ldapServer $primaryServerValue
                    }
                }
            }
        }
    }
    catch {
        Write-Error "External Identity Source Test failed: $_"
    }
}