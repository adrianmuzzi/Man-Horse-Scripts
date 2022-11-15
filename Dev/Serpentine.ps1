13 # Remove from groups
    $chosenGroup = ''
    Write-Host "`n-----------------------------------------------------------------------"
    Write-Host "   Remove from group..."
    Write-Host "(changes take a minute or so to appear)"
    Write-Host "-----------------------------------------------------------------------`n`n"
    Do {
        $groupMemberships = Get-MgUserMemberOf -UserID $userID -Count membershipCount -ConsistencyLevel eventual
        $groupMemberships = $groupMemberships.ID
        if($membershipCount -gt 1){
            $i = 0
            Do {
                Write-Host "$($i+1). $((Get-MgGroup -GroupId $groupmemberships[$i] | Where-Object {$_.DisplayName -ne "All Users"}).DisplayName)"
                $i++
            }Until($i -ge $groupMemberships.Length)
            $chosenGroup = Read-Host -Prompt "Which group would you like to leave? (or 'q' to go back)`n"
            if($chosenGroup -ne 'q'){
                $groupSelected = (Get-MgGroup -GroupId $groupMemberships[$chosenGroup-1])
                if($groupSelected){
                    Write-Host "Removing $($User.DisplayName) from $($groupSelected.DisplayName)..."
                    Try {
                        Remove-MgGroupMemberByRef -GroupId $groupSelected.ID -DirectoryObjectId $userID
                        Write-Host
                    }Catch{
                        Write-Host "...Failed"
                    }
                }else{
                    Write-Host "Error - No group found"
                }
            }
        }else{
            "$($User.DisplayName) is in only in one group - '$((Get-MgGroup -GroupId $groupmemberships).DisplayName)'`n"
            $chosenGroup = 'q'
        }
    } Until ($chosenGroup -eq 'q')
    Break

# add to groups
    Do {
        #get the ids of all the groups user is member of
        $groupMemberships = Get-MgUserMemberOf -UserID $userID -Count membershipCount -ConsistencyLevel eventual
        $groupmemberships = $groupmemberships.ID
        #get the ids of all the groups in tenant
        $gL = (Get-MgGroup -All).ID
        if(membershipCount -gt 1){
            #make a list of the user id for users not in both lists
            $pg = $gL | Where-Object { $_ -notin $groupMemberships }
            $potentialGroups = [Object[]]::new($pg.Length)
            $i = 0
            #convert these extracted group ids into group objects
            Do {
                $potentialGroups[$i] = Get-MgGroup -GroupId $pg[$i]
                $i++
            } Until($i -ge $pg.Length)
            #now we re-arrange the array of user objects alphabetically by display name
            $potentialGroups = $potentialGroups | Sort-Object -Property @{Expression = "DisplayName"}
            $i = 0
            #and write the alphabetical list of users
            Do{
                Write-Host "$($i+1). $(($potentialGroups[$i]).DisplayName)"
                $i++
            }Until($i -ge ($potentialGroups.Length))
        }else{
            $potentialGroups = Get-MgGroup -All | Where-Object {$_.DisplayName -ne "All Users"}
        }
        #pick a user and they get added to the group
                $chosenGroup = Read-Host -Prompt "`nEnter the number listed next to the group you want to add $($User.DisplayName) to (or 'q' to go back)`n"
                if (($chosenGroup -ne 'q') -and ($chosenGroup -ne "")){
                    $group = $potentialGroups[$chosenGroup-1]
                    if($group){
                        Write-Host "Adding $($User.DisplayName) to $($group.DisplayName)..."
                        Try {
                            New-MgGroupMember -GroupId $group.ID -DirectoryObjectId $User.ID
                            Write-Host "SUCCESS! Added $($User.DisplayName) to $($group.DisplayName)"
                        }Catch{
                            Write-Host "FAILED to add $($User.DisplayName) to $($group.DisplayName)"
                        }
                    }else{
                        Write-Host "Invalid Input - Could not find user..."
                    }
                }
    } Until ($chosenGroup -eq 'q')
    Break