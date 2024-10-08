function Install-RequiredModule {
    param (
        [string]$moduleName
    )
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Output "$moduleName module not found. Installing..."
        Install-Module -Name $moduleName -AllowClobber -Scope CurrentUser -Force
        Write-Output "$moduleName module installed successfully!"
    } else {
        Write-Output "$moduleName module is already installed."
    }
}