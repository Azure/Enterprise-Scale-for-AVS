. .\New-IfNotExist-ContentLibrary.ps1
. .\New-IfNotExist-ContentLibraryItem.ps1
. .\New-IfNotExist-ApplianceFile.ps1
. .\New-IfNotExist-VM-From-OVA.ps1
. .\New-IfNotExist-HCX-Location.ps1
. .\New-IfNotExist-HCX-vCenterConfig.ps1
. .\New-IfNotExist-HCX-SSOConfig.ps1
. .\New-IfNotExist-HCX-LicenseKey.ps1
. .\New-IfNotExist-HCX-RoleMappings.ps1
. .\Restart-HCX-Services.ps1
function Start-Processing {
    param (
        [string]$ParameterFile,
        [secureString]$vCenterPassword
    )

    try {
        # Source the parameter file inside the function to get access to all parameters
        . $ParameterFile
        
        # Check and create the Content Library if it does not exist
        $contentLibraryID = New-IfNotExist-ContentLibrary -vCenter $vCenter `
            -vCenterUserName $vCenterUserName `
            -vCenterPassword $vCenterPassword `
            -datastoreName $datastoreName `
            -contentLibraryName $contentLibraryName

        # If the content library creation failed, exit the script
        if (-not $contentLibraryID) {
            return
        }

        # Check and create the Content Library Item if it does not exist
        $libraryItemID = New-IfNotExist-ContentLibraryItem -vCenter $vCenter `
            -vCenterUserName $vCenterUserName `
            -vCenterPassword $vCenterPassword `
            -contentLibraryID $contentLibraryID `
            -contentLibraryitemName $contentLibraryitemName

        # If the content library item creation failed, exit the script
        if (-not $libraryItemID) {
            return
        }

        # Check and Upload the appliace file to the Content Library Item
        $applianceStatus = New-IfNotExist-ApplianceFile -vCenter $vCenter `
            -vCenterUserName $vCenterUserName `
            -vCenterPassword $vCenterPassword `
            -contentLibraryItemID $libraryItemID `
            -applianceFilePath $applianceFilePath

        # If the appliance file upload failed, exit the script
        if (-not $applianceStatus) {
            return
        }
            
        # New VM from OVA
        New-IfNotExist-VM-From-OVA -vCenter $vCenter `
            -vCenterUserName $vCenterUserName `
            -vCenterPassword $vCenterPassword `
            -contentLibraryItemID $libraryItemID `
            -segmentName $segmentName `
            -applianceVMName $applianceVMName `
            -applianceVMIP $applianceVMIP `
            -applianceVMGatewayIP $applianceVMGatewayIP `

        # Check if HCX URL is up and running until it is reachable
        $abshcxUrl = $hcxUrl.TrimEnd('/')

        # Starting HCX configuration
        Write-Host "Starting HCX configuration for URL: $hcxUrl"

        $hcxConfigurationInComplete = $true
        while ($hcxConfigurationInComplete) {        
            # Check if HCX URL is reachable
            $response = Invoke-WebRequest -Uri $abshcxUrl -UseBasicParsing -TimeoutSec 10 -SkipCertificateCheck
            if ($response.StatusCode -eq 200) {
                Write-Host "HCX URL is reachable: $hcxUrl"

                # Set HCX Location
                New-IfNotExist-HCX-Location -vCenterPassword $vCenterPassword `
                    -hcxUrl $hcxUrl

                # Check and create HCX vCenter Configuration
                New-IfNotExist-HCX-vCenterConfig -vCenter $vCenter `
                    -vCenterUserName $vCenterUserName `
                    -vCenterPassword $vCenterPassword `
                    -hcxUrl $hcxUrl
                    
                # Check and create HCX SSO Configuration
                New-IfNotExist-HCX-SSOConfig -vCenter $vCenter `
                    -vCenterPassword $vCenterPassword `
                    -hcxUrl $hcxUrl

                # Check and create HCX License Key
                New-IfNotExist-HCX-LicenseKey -vCenterPassword $vCenterPassword `
                    -hcxUrl $hcxUrl `
                    -hcxLicenseKey $hcxLicenseKey
                    
                # Check and create HCX Role Mappings
                New-IfNotExist-HCX-RoleMappings -vCenter $vCenter `
                    -vCenterUserName $vCenterUserName `
                    -vCenterPassword $vCenterPassword `
                    -hcxUrl $hcxUrl `
                    -hcxAdminGroup $hcxAdminGroup

                # Restart HCX Services                
                Restart-HCX-Services -vCenterPassword $vCenterPassword `
                    -hcxUrl $hcxUrl
                    
                $hcxConfigurationInComplete = $false  # Set to false to exit the loop

                break  # Exit the while loop since HCX is configured successfully
            }
        }
        Write-Host "HCX deployment and configuration completed successfully."
        Write-Host "You can now access HCX at: $hcxUrl"
    } catch {
        if ($hcxConfigurationInComplete){
            Write-Host "HCX service is still booting up, retrying in 1 minute..."
            Start-Sleep -Seconds 60
        }     
    }
}