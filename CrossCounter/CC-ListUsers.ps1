<#
    .SYNOPSIS
    Creates CrossCounter User List
    
    .PARAMETER property
    Can be "email", "mobile" or "jobTitle" 
#>
Do {
    Write-Host @"
|======================================|
LIST USERS                
[1.] Name only                             
[2.] Name + Email                   
[3.] Name + Mobile Phone     
[4.] Name + Job Title
[5.] Name + License(s)
[Q.] Go back               
|======================================|
"@ -ForegroundColor Yellow
    $listUserOpt = Read-Host
    if($listUserOpt -eq 'q'){
        return
    }
}Until($listUserOpt)

    Write-Host @"
==================================================================
$($tenantName) Users
==================================================================`n
"@ -ForegroundColor Yellow
    $uL = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
    $i = 0
    Do{
        switch($listUserOpt){
            2 {
                $prop = " - $($uL[$i].Mail)"
            }
            3 {
                $prop = " - $($uL[$i].MobilePhone)"
            }
            4 {
                $prop = " - $($uL[$i].JobTitle)"
            }
            5 { #to be changed
                $SKUS = Get-MgUserLicenseDetail -UserID $uL[$i].Id
                $prop = " - "
                if($SKUS.count -gt 1){
                    $ii = 0
                    Do{
                        $prop += ", " 
                        $prop += . $CrossCounterSkuToProduct -SKU $SKUS[$ii].SkuId
                        $ii++
                    }Until($ii -ge $SKUS.count)
                }else{
                    $prop += . $CrossCounterSkuToProduct -SKU $SKUS.SkuId
                }
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
