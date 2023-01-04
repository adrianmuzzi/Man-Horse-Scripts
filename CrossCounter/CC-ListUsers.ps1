<#
    .SYNOPSIS
    Creates CrossCounter User List
    
    .PARAMETER property
    Can be "email", "mobile" or "jobTitle" 
#>
param (
    # What we want listed next to the name
    [string]$property = ""
)
    Write-Host @"
===============================================================================
          ___  ___  __   __
    |  | /__' |__  |__) /__' 
    \__/ .__/ |___ |  \ .__/ 
===============================================================================
"@ -ForegroundColor Yellow
    $uL = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
    $i = 0
    Do{
        switch($property){
            "email" {
                $prop = " - $($uL[$i].Mail)"
            }
            "mobile" {
                $prop = " - $($uL[$i].MobilePhone)"
            }
            "jobTitle" {
                $prop = " - $($uL[$i].JobTitle)"
            }
            default {
                $prop = ""
            }
        }
        Write-Host "$($i+1). $($uL[$i].DisplayName)$($prop)"
        $i++
    }Until($i -ge ($userCount))
    
    Write-Host "`n$userCount users - Listed alphabetically by display name" -ForegroundColor DarkGray
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console" -ForegroundColor DarkGray
    return $uL
