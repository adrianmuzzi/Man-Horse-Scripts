<#
    .SYNOPSIS
    Removes a user from a M365 group

    .PARAMETER groupID
    The ObjectID of the group you want to remove a member from
#>

param (
    [string]$GroupId
)
$groupSelected = Get-MgGroup -GroupId $groupID
Write-Host "------------------------------------------------------------------------------------------------"-ForegroundColor DarkRed
Write-Host " REMOVING members from $($groupSelected.DisplayName)" -ForegroundColor DarkRed
Write-Host " (Note changes may take a minute or two to cache)" -ForegroundColor DarkGray
Write-Host "------------------------------------------------------------------------------------------------`n"-ForegroundColor DarkRed
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
#pick a user and they get removed from the group
Do {
    $chosenUser = Read-Host -Prompt "`nEnter the number listed next to the user you want to remove from the '$($groupSelected.DisplayName)' group (or 'q' to go back)`n"
    if (($chosenUser -ne 'q')){
        $member = $mL[$chosenUser-1]
        if($member){
            Write-Host "Removing $($member.DisplayName) from $($groupSelected.DisplayName)..."
            Try {
                # need this for the graph query below; it needs a $ref tacked on at the end. By setting the variable to '$ref' it does not get interpreted as a variable.
                Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $member.ID
                Write-Host "SUCCESS!"
            }Catch{
                Write-Host "...`nFAILED! to remove $($member.DisplayName) from $($groupSelected.DisplayName)"
                Write-Host $_
            }
        }else{
            Write-Host "Invalid Input - Could not find user..." -ForegroundColor DarkRed
        }
    }
}Until ($chosenUser -eq "q")