if($Authentication -eq 'Application'){
    Write-Host "Attempting to connect to graph tenant at $azureDomain" -ForegroundColor DarkGray
    $clientID = ""
    $authority = "https://login.windows.net/$AzureTenantID"
    Update-MsGraphEnvironment -AppId $clientID -Quiet
    Update-MsGraphEnvironment -AuthURL $authority -Quiet
    $GraphConnection = Connect-MSGraph -ClientSecret $ClientSecret -PassThru
    Connect-Graph -AccessToken $GraphConnection | Out-Null
    Write-Host "Successfully connected to $AzureTenantID" -ForegroundColor Green
}