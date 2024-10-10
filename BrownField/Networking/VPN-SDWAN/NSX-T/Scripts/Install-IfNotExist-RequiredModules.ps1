function Install-RequiredModule {
    param (
        [string]$moduleName
    )

    # Check if the module is already installed
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Output "$moduleName module not found. Installing..."
        Install-Module -Name $moduleName -AllowClobber -Scope CurrentUser -Force
        Write-Output "$moduleName module installed successfully!"
    } else {
        Write-Output "$moduleName module is already installed."
    }

    # Import the module if not already imported
    if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
        Write-Output "Importing module $moduleName..."
        Import-Module -Name $moduleName -ErrorAction Stop -Verbose
    } else {
        Write-Output "Module $moduleName is already imported."
    }
}

function Install-IfNotExist-RequiredModules {
    # Check if the required type is already loaded
    if (-not ([type]::GetType("Microsoft.Azure.Commands.Common.Authentication.AzureSession", $false, $false))) {
        # Check and install required modules
        Install-RequiredModule -moduleName Az
    } else {
        Write-Output "Type Microsoft.Azure.Commands.Common.Authentication.AzureSession is already loaded."
    }

    # Add User Agent
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("pid-94c42d97-a986-4d59-a0e6-6cd5aea77442")
}