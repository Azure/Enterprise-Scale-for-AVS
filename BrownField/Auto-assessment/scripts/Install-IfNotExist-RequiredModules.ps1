function Install-RequiredModule {
    param (
        [string]$moduleName
    )

    # Check if the module is already installed
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Host "$moduleName module not found. Installing..."
        Install-Module -Name $moduleName -AllowClobber -Scope CurrentUser -Force
        Write-Host "$moduleName module installed successfully!"
    } else {
        Write-Host "$moduleName module is already installed."
    }

    # Import the module if not already imported
    if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
        Write-Host "Importing module $moduleName..."
        Import-Module -Name $moduleName -ErrorAction Stop -Verbose
    } else {
        Write-Host "Module $moduleName is already imported."
    }
}

function Install-IfNotExist-RequiredModules {
    # Check if the required type is already loaded
    Install-RequiredModule -moduleName Az.Accounts
    #Install-RequiredModule -moduleName Microsoft.Graph.Identity.DirectoryManagement
}