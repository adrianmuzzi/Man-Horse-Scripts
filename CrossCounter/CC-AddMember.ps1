<#
    .SYNOPSIS
    Adds a user to an M365 group

    .PARAMETER groupID
    The ObjectID of the group you want to add a member to
#>
param (
    $groupID
)
Do {
    $groupSelected = Get-MgGroup -GroupId $groupID
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor DarkGreen
    Write-Host " ADDING members to $($groupSelected.DisplayName)" -ForegroundColor Magenta
    Write-Host " (Note changes may take a minute or two to cache)" -ForegroundColor DarkGray
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor DarkGreen
#get the ids of all the members of the group
    $mIdL = Get-MgGroupMember -GroupId $groupID -Count memberCount -ConsistencyLevel eventual
    $mL = $mIdL.Id
#get the ids of all the users in tenant
    $uL = (Get-MgUser -Count userCount -ConsistencyLevel eventual).ID
#make a list of the user id for users not in both lists
    $pm = $uL | Where-Object { $_ -notin $mL }
    $potentialMembers = [Object[]]::new($pm.Length)
    $i = 0
#convert these extracted user ids into user objects
    Do {
        $potentialMembers[$i] = (Get-MgUser -UserId ($pm[$i]))
        $i++
    } Until($i -ge $pm.Length)
#now we re-arrange the array of user objects alphabetically by display name
    $potentialMembers = $potentialMembers | Sort-Object -Property @{Expression = "DisplayName"}
    $i = 0
#and write the alphabetical list of users
    Do{
        Write-Host "$($i+1). $(($potentialMembers[$i]).DisplayName)"
        $i++
    }Until($i -ge ($potentialMembers.Length))
    $chosenUser = ""
#pick a user and they get added to the group
        $chosenUser = Read-Host -Prompt "`nEnter the number listed next to the user you want to add to the '$($groupSelected.DisplayName)' group (or 'q' to go back)`n"
        if (($chosenUser -ne 'q')){
            $member = $potentialMembers[$chosenUser-1]
            if($member){
                Write-Host "Adding $($member.DisplayName) to $($groupSelected.DisplayName)..."
                Try {
                    New-MgGroupMember -GroupId $groupID -DirectoryObjectId $member.ID
                    Write-Host "SUCCESS! Added $($member.DisplayName) to $($groupSelected.DisplayName)"
                }Catch{
                    Write-Host "FAILED to add $($member.DisplayName) to $($groupSelected.DisplayName)"
                }
            }else{
                Write-Host "Invalid Input - Could not find user..."
            }
        }
} Until ($chosenUser -eq "q")