function Get-Azure-Token {
    return (Get-AzAccessToken -ResourceUrl "https://management.azure.com/").Token
}