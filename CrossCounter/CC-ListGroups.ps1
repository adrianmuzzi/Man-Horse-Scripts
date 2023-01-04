<#
    .SYNOPSIS
    Creates CrossCounter Group List
#>
Write-Host @"
===============================================================================                                                     
     __   __   __        __   __  
    / _' |__) /  \ |  | |__) /__' 
    \__> |  \ \__/ \__/ |    .__/ 
================================================================================
"@ -ForegroundColor DarkMagenta
        Write-Host "`n"
        $i = 0
        $gL = Get-MgGroup -All -Count groupCount -ConsistencyLevel eventual -OrderBy DisplayName | Sort-Object -Property @{Expression = "DisplayName"}
        Do{
            Write-Host "$($i+1). $($gL[$i].DisplayName) --- $($gL[$i].Description)"
            $i++
        }Until($i -ge ($groupCount))
        Write-Host "`n$groupCount groups - Listed alphabetically" -ForegroundColor DarkGray
        Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console" -ForegroundColor DarkGray
        return $gL