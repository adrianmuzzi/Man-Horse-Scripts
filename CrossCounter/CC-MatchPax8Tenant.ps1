Try {
    Try {
        $config = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent
        $config = Get-Content "$($config)\.config.json" | ConvertFrom-Json
        $clientID=$config.PAX8_ID
        $clientSecret=$config.PAX8_SECRET
    }Catch{
        Write-Host "While connecting to Pax8, CrossCounter could not find .config.json, or there was an error pulling credentials from it." -ForegroundColor Red
        return
    }
    $clientSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($clientID, $clientSecret)
    Connect-Pax8 -credential $cred
    Write-Host "Pax8 Connected..." -ForegroundColor Green
    $allCompanies = Get-Pax8Company
    $progressBar = "Searching Pax8..."
    Write-Host $progressBar -NoNewLine
    $i=0
    Do {
            if ($allCompanies[$i].status -ne 'Deleted'){
                $current = Get-Pax8Company365TenantId $allCompanies[$i].id
                if  ($current -eq $tenantID){
                    Write-Host "Pax8 has found a matching tenant ID for $($tenantName):" -ForegroundColor Green
                    Write-Host $allCompanies[$i].name -ForegroundColor DarkGreen
                    return $allCompanies[$i]
                }
            }
            for ($pb = 0; $pb -lt $progressBar.Length; $pb++){
                Write-Host "`b" -NoNewLine
            }
            Write-Host "$(($i / $allCompanies.Count) * 100)% of integrated Pax8 companies searched..." -NoNewline
            $progressBar = "$(($i / $allCompanies.Count) * 100)% of integrated Pax8 companies searched..."
    $i++
    }Until($i -ge $allCompanies.count)
    for ($pb = 0; $pb -lt $progressBar.Length; $pb++){
        Write-Host "`b" -NoNewLine
    }
    Write-Host "Pax8 integration could not match the $($tenantName) tenant ID against $($allCompanies.count) detected companies in its system." -ForegroundColor Red
}Catch{
    Write-Host $_ -ForegroundColor DarkRed
    Write-Host "Pax8 integration failed." -ForegroundColor Red
}