#=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-=
#'off' for User offboarding
switch ($x) {
    'off' {
        Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`nUser Offboarding`n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`n"
        Do {
            $chosenOption = Read-Host -Prompt "Enter the number listed next to the user set for Offboarding (or 'q' to go back)`n"
            Try {
                $User = $userList[($chosenOption-1)]
                $userID = $User.ID
            } Catch {
                Write-Host "Invalid Input - No user found listed under that number..."
            }
            if ($User) {
                Write-Host "OFFBOARDING FOR $($User.DisplayName)`n$($User.Mail)..."
                Write-Host "!! WARNING !! CONFIRM YOU MEAN TO OFFBOARD THIS USER !! $($userID)"
                $chosenOption = Read-Host -Prompt "(y/n)"
                if (($chosenOption -eq 'y') -or (($chosenOption -eq 'Y'))){
                    Write-Host "OFFBOARDING FOR $($User.DisplayName)`n$($User.Mail)..."
                    Write-Host "(this may take a moment...`n)"
                    
                    #1. Reset Password
                    Write-Host "1. - RESETTING PASSWORD..."
                    $newPass = GeneratePassword
                    $authMethod = Get-MgUserAuthenticationMethod -UserId $userID
                    try {
                        Reset-MgUserAuthenticationMethodPassword -UserId $userID -AuthenticationMethodId $authMethod.Id -NewPassword $newPass
                        Write-Host "Password Reset... SUCCESS"
                    }catch{
                        Write-Host $_.ScriptStackTrace
                        Write-Host "Password Reset... FAILED"
                    }
                    
                    #2. Remove from all groups
                    Write-Host "`n2. - REMOVING FROM GROUPS"        
                    $groupMemberships = Get-MgUserMemberOf -UserID $userID
                    $groupMemberships = $groupMemberships.ID            
                    $i = 0
                    Do {
                        Try {
                            Remove-MgGroupMemberByRef -GroupId $groupMemberships[$i] -DirectoryObjectId $userID
                            Write-Host "$((Get-MgGroup -GroupId $groupMemberships[$i]).DisplayName)... SUCCESS"
                        }Catch{
                            Write-Host "$((Get-MgGroup -GroupId $groupMemberships[$i]).DisplayName)... FAIL"
                        }
                        $i++
                    }Until($i -ge $groupMemberships.Length)
                    Write-Host "Re-listing user's group membersips... (It is expected that some group memberships will remain, eg. 'All Users')"
                    $memarr = Get-MgUserMemberOf -UserID $userID
                    $memarr = $memarr.ID
                    $i = 0
                    Do {
                        Write-Host (Get-MgGroup -GroupId $memarr[$i]).DisplayName
                        $i++
                    }Until($i -ge $memarr.Length)
                    
                    #3.
                }
            }else{
                    Write-Host "Invalid Input - Enter the number listed next to the user"
            }
        } Until ($chosenOption = 'q')
    Break
    }
}
#=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-=