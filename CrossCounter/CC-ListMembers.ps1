<#
    .SYNOPSIS
    Lits members in a M365 group for CrossCounter

    .PARAMETER GroupId
    The ObjectID of the group
#>
param (
    [string]$GroupId
)
$groupSelected = Get-MgGroup -GroupId $groupID
Write-Host "=================================================================================================" -ForegroundColor DarkGreen
Write-Host "Editing $($groupSelected.DisplayName)" -ForegroundColor Green
Write-Host "(Note changes may take a minute or two to cache)" -ForegroundColor DarkGray
Write-Host "=================================================================================================`n" -ForegroundColor DarkGreen
$i = 0
#The objects in this array only contain the user IDs of the group members (as well as other inconsequential info)
$mIdL = Get-MgGroupMember -GroupId $GroupId -Count memberCount -ConsistencyLevel eventual
$mL = [Object[]]::new($memberCount)
#First we convert these extracted userIds into user objects
Do {
    $mL[$i] = (Get-MgUser -UserId ($mIdL[$i].Id))
    $i++
} Until($i -ge $memberCount)
#now we re-arrange the array of user objects alphabetically by display name
$mL = $mL | Sort-Object -Property @{Expression = "DisplayName"}
$i = 0
#and write the alphabetical list of users
Do{
    Write-Host "$($i+1). $(($mL[$i]).DisplayName)"
    $i++
}Until($i -ge ($memberCount))
Write-Host "`n$memberCount members of $($groupSelected.DisplayName) - Listed alphabetically..."
return $mL