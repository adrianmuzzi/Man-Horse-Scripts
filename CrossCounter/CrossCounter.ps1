<# Barclay McClay - 2022 #>
Write-Host " __   __   __   __   __      __   __            ___  ___  __  " -ForegroundColor Yellow
Write-Host "/  ' |__) /  \ /__' /__'    /  ' /  \ |  | |\ |  |  |__  |__) " -ForegroundColor Yellow
Write-Host "\__, |  \ \__/ .__/ .__/    \__, \__/ \__/ | \|  |  |___ |  \ " -ForegroundColor Yellow
Write-Host "-- -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ --`n" -ForegroundColor DarkYellow
#################################################################################
#Check if we have the Microsoft Graph Powershell Module, If we don't; Install it
if(-not (Get-Module Microsoft.Graph -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module Microsoft.Graph -Scope CurrentUser
}
# ==============================================================================
#                             DEFINE FUNCTIONS
# ==============================================================================
function Get-MnemonicWord {
    try {
        $WordListUri = "https://raw.githubusercontent.com/chelnak/MnemonicEncodingWordList/master/mnemonics.json"
        $WordListObject = Invoke-RestMethod -Method Get -Uri $WordListUri
        $w = Get-Random -InputObject $WordListObject.words -Count 1
        return $w
    }
    catch [Exception]{
        throw "Could not retrieve Mnemonic Word List: $($Exception.Message)"
    } 
}
function GeneratePassword {
    param (
        $PWStrength
    )
    $n = Get-Random -Maximum 10000
    $nn = Get-Random -Maximum 100
    $word = Get-MnemonicWord
    $word2 = Get-MnemonicWord
    $letterList = "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","!","?","@","#", "&","=","%"
    switch ($PWStrength) {
        1 {     
            $pass = "$($word)$($nn)$($word2.ToUpper())"
            Break
        }
        2 { 
            $pass = "$($word)$($word2)$($nn)$($letterList.ToUpper() | Get-Random)"
            Break
        }
        3 { 
            $passArr = $($word),$($word2),$($n),$($letterList.ToUpper() | Get-Random),$($letterList.ToUpper() | Get-Random) | Get-Random -Shuffle
            $pass = [String]::Join("",$passArr)
            Break
        }
        4 {
            $passArr = $($n),$($letterList.ToUpper() | Get-Random),$($letterList.ToUpper() | Get-Random),$($letterList.ToUpper() | Get-Random),$($nn),$($letterList | Get-Random),$($letterList | Get-Random),$($letterList | Get-Random),$($letterList | Get-Random),$($letterList | Get-Random),$($letterList | Get-Random)  | Get-Random -Shuffle
            $pass = [String]::Join("",$passArr)
            Break
        }
        5 { 
            $passArr = $n, $nn, $word, ($letterList | Get-Random), ($letterList.ToUpper() | Get-Random), ($letterList.ToUpper() | Get-Random), ($letterList.ToUpper() | Get-Random), ($letterList.ToUpper() | Get-Random),($letterList.ToUpper() | Get-Random),($letterList | Get-Random),($letterList | Get-Random),($letterList | Get-Random),($letterList | Get-Random),($letterList | Get-Random),($letterList | Get-Random) | Get-Random -Shuffle
            $pass = [String]::Join("",$passArr)
            Break
        }
    }
    return $pass
}
function CrossCounterListUsers {
    Write-Host "`n----------------------------------------------------------------------------------
          ___  ___  __   __
    |  | /__' |__  |__) /__' 
    \__/ .__/ |___ |  \ .__/ 
----------------------------------------------------------------------------------" -ForegroundColor DarkGreen
    $uL = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
    $i = 0
    Do{
        Write-Host "$($i+1). $($uL[$i].DisplayName)       --- ---       $($uL[$i].Mail)"
        $i++
    }Until($i -ge ($userCount))
    Write-Host "`n$userCount users - Listed alphabetically by display name" -ForegroundColor DarkGray
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console" -ForegroundColor DarkGray
    return $uL
}
function CrossCounterListGroups {
    Write-Host "`n"
    Write-Host "===============================================================================                                                     
     __   __   __        __   __  
    / _' |__) /  \ |  | |__) /__' 
    \__> |  \ \__/ \__/ |    .__/ 
================================================================================" -ForegroundColor DarkMagenta
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
}
function CrossCounterListMembers {
    param (
        $GroupId
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
}
function CrossCounterAddMember {
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
}
function CrossCounterRemoveMember {
    param (
        $GroupId
    )
    $groupSelected = Get-MgGroup -GroupId $groupID
    Write-Host "------------------------------------------------------------------------------------------------"-ForegroundColor DarkRed
    Write-Host " REMOVING members from $($groupSelected.DisplayName)" -ForegroundColor Magenta
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
}
function CrossCounterEditUser {
    param (
        $userID
    )
    Do {
        $User = Get-MgUser -UserId $userID
        Write-Host "=================================================================================================" -ForegroundColor Blue
        Write-Host "Editing $($User.DisplayName)" -ForegroundColor Green
        Write-Host "(Note changes may take a minute or two to cache, only options 1-7 preview in this menu)" -ForegroundColor DarkGray
        Write-Host "=================================================================================================" -ForegroundColor Blue
<# 
Certain attributes like 'CompanyName' and 'PostalCode' can only be called va Select-Object... and even then
there appears to be a bug where some properties refuse to display correctly. As a result- not all Properties in this list
show a 'preview'; you have to take the script at its word.
Also, edits take a few moments to tick-over, so while it may appear like changes are not being made- be assured that they are. 
#>
Write-Host "
[1.] Display Name:            $($User.DisplayName)
[2.] First Name:              $($User.GivenName)
[3.] Last Name:               $($User.Surname)
[4.] Job Title:               $($User.JobTitle)
[5.] Mobile Phone:            $($User.MobilePhone)
[6.] Business Phone:          $($User.BusinessPhones)
[7.] Email Address:           $($User.Mail)
[8.] Department               $($User.Department)
[9.] Street address           $($User.StreetAddress)
[10.] City                    $($User.City)
[11.] Postal Code             $($User.PostalCode)
[12.] Country                 $($User.Country)
[13.] Company Name            $($User.CompanyName)
[14.] Reset Password
"
        $chosenOption = Read-Host -Prompt "What would you like to change? (Input Number, or 'q' to go back)"

        switch ($chosenOption) {
            1 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.DisplayName)' to?"
                Update-MgUser -UserId $userID -DisplayName $editMade;
                $fullName = $editMade.split(" ",2)
                Do{
                    $yesno = Read-Host -Prompt "Would you also like to change Given Name '$($User.GivenName)' to '$($fullName[0])'`nAnd Surname '$($User.Surname)' to '$($fullName[1])'?`n(y/n)"
                }Until(($yesno -eq 'y') -or ($yesno -eq 'n'))
                if(($yesno -eq 'y') -or ($yesno -eq 'Y')){
                    Update-MgUser -UserId $userID -GivenName ($fullName[0])
                    Update-MgUser -UserId $userID -Surname ($fullName[1])
                }
            Break
            }
            2 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.GivenName)' to?"
                Update-MgUser -UserId $userID -GivenName $editMade
                Break
            }
            3 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.Surname)' to?"
                Update-MgUser -UserId $userID -Surname $editMade
                Break
            }
            4 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.JobTitle)' to?"
                Update-MgUser -UserId $userID -JobTitle $editMade
                Break
            }
            5 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.MobilePhone)' to?"
                Update-MgUser -UserId $userID -MobilePhone $editMade
                Break
            }
            6{
                $editMade = Read-Host -Prompt "What would you like to change '$($User.BusinessPhones)' to?"
                Update-MgUser -UserId $userID -BusinessPhones $editMade
                Break
            }
            7 {
                $editMade = CrossCounterEditUserMail -userID $userID
                if($editMade -ne ""){
                    Try {
                        Write-Host "...`n"
                        Update-MgUser -UserId $userID -Mail $editMade
                        Write-Host "Success - New email is: $($editMade)"
                    }Catch{
                        Write-Host "Error - Email update failed"  -ForegroundColor DarkRed
                    }
                }
                Break
            }
            8 {
                $editMade = Read-Host -Prompt "What would you like to change the department to?"
                Update-MgUser -UserId $userID -Department $editMade
                Break
            }
            9 {
                $editMade = Read-Host -Prompt "What would you like to change the street address to?"
                Update-MgUser -UserId $userID -StreetAddress $editMade
                Break
            }
            10 {
                $editMade = Read-Host -Prompt "What would you like to change the city to?"
                Update-MgUser -UserId $userID -City $editMade
                Break
            }
            11 {
                $editMade = Read-Host -Prompt "What would you like to change postal code to?"
                Update-MgUser -UserId $userID -PostalCode $editMade
                Break
            }
            12 {
                $editMade = Read-Host -Prompt "What would you like to change the Country to?"
                Update-MgUser -UserId $userID -Country $editMade
                Break
            }
            13 {
                $editMade = Read-Host -Prompt "What would you like to change the company name to?"
                Update-MgUser -UserId $userID -CompanyName $editMade
                Break
            }
            14 {
                CrossCounterEditUserPassword -userID $userID
                Break
            }
        }
    }Until($chosenOption -eq 'q')
}
function CrossCounterEditUserMail {
    param (
        $userID
    )
    $i = 0 
    Do {
        $editMade = ""
        $User = Get-MgUser -UserId $userID      
        $mail = $User.Mail -Split "@"
        $fname = ($User.GivenName -replace '[\W]', '').ToLower() #sanitized for special characters
        $sname = ($User.Surname -replace '[\W]', '').ToLower()   #sanitized for special characters
        $mailOpt = "0","custom","no change","janesmith","jane.smith","jsmith","j.smith","janes","jane.s","js","j.s","smithj", "smith.j", "smithjane", "smith.jane"
        $i++
        $mailOpt[$i] = "";
        Write-Host "`n$($i). - Custom input -"
        $i++
        $mailOpt[$i] = "";
        Write-Host "`n$($i). - No Change -"
        $i++
        $mailOpt[$i] = "$($fname)$($sname)@$($mail[1])"        # janesmith@domain
        Write-Host "`n$($i). $($mailOpt[$i])"                 
        $i++
        $mailOpt[$i] = "$($fname).$($sname)@$($mail[1])"       # jane.smith@domain
        Write-Host "`n$($i). $($mailOpt[$i])"
        $i++
        $mailOpt[$i] = "$($fname.Substring(0,1))$($sname)@$($mail[1])"   # jsmith@domain
        Write-Host "`n$($i). $($mailOpt[$i])"
        $i++
        $mailOpt[$i] = "$($fname.Substring(0,1)).$($sname)@$($mail[1])"  # j.smith@domain
        Write-Host "`n$($i). $($mailOpt[$i])"  
        $i++ 
        $mailOpt[$i] = "$($fname)$($sname.Substring(0,1))@$($mail[1])"     # janes@domain
        Write-Host "`n$($i). $($mailOpt[$i])"
        $i++ 
        $mailOpt[$i] = "$($fname).$($sname.Substring(0,1))@$($mail[1])"     # jane.s@domain
        Write-Host "`n$($i). $($mailOpt[$i])"  
        $i++ 
        $mailOpt[$i] = "$($fname.Substring(0,1))$($sname.Substring(0,1))@$($mail[1])" # js@domain
        Write-Host "`n$($i). $($mailOpt[$i])" 
        $i++ 
        $mailOpt[$i] = "$($fname.Substring(0,1)).$($sname.Substring(0,1))@$($mail[1])" # j.s@domain
        Write-Host "`n$($i). $($mailOpt[$i])"
        $i++ 
        $mailOpt[$i] = "$($sname).$($fname.Substring(0,1))@$($mail[1])" # smithj@domain
        Write-Host "`n$($i). $($mailOpt[$i])" 
        $i++ 
        $mailOpt[$i] = "$($sname).$($fname.Substring(0,1))@$($mail[1])" # smith.j@domain
        Write-Host "`n$($i). $($mailOpt[$i])"
        $i++ 
        $mailOpt[$i] = "$($sname)$($fname)@$($mail[1])" # smithjane@domain
        Write-Host "`n$($i). $($mailOpt[$i])" 
        $i++ 
        $mailOpt[$i] = "$($sname).$($fname)@$($mail[1])" # smith.jane@domain
        Write-Host "`n$($i). $($mailOpt[$i])" 
        $editMade = Read-Host -Prompt "`nWhat would you like to change '$($User.Mail)' to? (Pick an option above)`n"
    
    }Until($editMade -ne "")
    switch ($editMade) {
        0 { 
            return ""
            Break
        }
        1 {
            Write-Host
            $custInput = Read-Host -Prompt "-CUSTOM-`nWhat would you like to change ____________$($mail[1]) to?`n"
            return $custInput+$mail[1]
            Break}
        2 {
            return ""
            Break
        }
        Default {
            return $mailOpt[$editMade]
        }
    }
    
}
function CrossCounterEditUserPassword {
    param (
        $userID
    )
    #Reset Password
    Write-Host "/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\" -ForegroundColor DarkBlue
    Write-Host " Reset Password..."
    Write-Host "/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\`n" -ForegroundColor DarkBlue
    Write-Host "
CrossCounter Passwords don't contain the user's ID and are least 8 characters long with at least 3 of the following: 
Upper-case letter, lower-case letter, number, symbol."
#populate list of preset options
    $i = 0
    Do {
        $editMade = ""
        $passOpt = "0","custom","No Change","1","2","3","4","5"
        $i++
        $passOpt[$i] = "";
        Write-Host "`n$($i). - Custom input -"
        $i++
        $passOpt[$i] = "";
        Write-Host "`n$($i). - No Change -"
        $i++
        $passOpt[$i] = "$(GeneratePassword -PWStrength 1)"
        Write-Host "`n$($i). $($passOpt[$i])"                 
        $i++
        $passOpt[$i] = "$(GeneratePassword -PWStrength 2)"
        Write-Host "`n$($i). $($passOpt[$i])"
        $i++
        $passOpt[$i] = "$(GeneratePassword -PWStrength 3)"
        Write-Host "`n$($i). $($passOpt[$i])"
        $i++
        $passOpt[$i] = "$(GeneratePassword -PWStrength 4)"
        Write-Host "`n$($i). $($passOpt[$i])"
        $i++
        $passOpt[$i] = "$(GeneratePassword -PWStrength 5)"
        Write-Host "`n$($i). $($passOpt[$i])"
        #prot user to select option
        $editMade = Read-Host -Prompt "`nPick an option above to reset the user's password`n"
    }Until($editMade -ne "")
    switch ($editMade) {
        0 { 
            $newPass =  ""
            Break
        }
        1 {
            $custInput = Read-Host -Prompt "-CUSTOM-`nPasswords can't contain the user's ID and need to be at least 8 characters long with at least 3 of the following: upper-case letters, lower-case letters, numbers and symbols.`nWhat would you like to change the password to?`n"
            if($custInput.Length -ge 8){
            $newPass =  $custInput
            }else{
                Write-Host "Error - Passwords can't contain the user's ID and should be at least 8 characters long with at least 3 of the following: upper-case letters, lower-case letters, numbers and symbols."
                Write-Host "Plase try again with a different password." -ForegroundColor Red
                $newPass =  ""
            }
            Break
        }
        2 {
            $newPass =   ""
            Break
        }
        'q' {
            $newPass =   ""
            Break
        }
        Default {
            if($passOpt[$editMade].Length -ge 8){
                $newPass = $passOpt[$editMade]
            }else{
                Write-Host "Error - Passwords can't contain the user's ID and should be at least 8 characters long with at least 3 of the following: upper-case letters, lower-case letters, numbers and symbols."
                Write-Host "Plase try again with a different password."  -ForegroundColor Red
                $newPass =  ""
            }
        }
    }
    if(($newPass -ne "")){
        $reqnextsign = Read-Host -Prompt "Require Change on next sign-in? (y/n)"
        try {
            $authMethod = Get-MgUserAuthenticationMethod -UserId $userID
            if(($reqnextsign -eq 'y') -or ($reqnextsign -eq 'Y')){
                Reset-MgUserAuthenticationMethodPassword -UserId $userID -AuthenticationMethodId $authMethod.Id -NewPassword $newPass -RequireChangeOnNextSignIn
            }else{
                Reset-MgUserAuthenticationMethodPassword -UserId $userID -AuthenticationMethodId $authMethod.Id -NewPassword $newPass
            }
            Write-Host "Password Reset... SUCCESS" -ForegroundColor DarkGreen
            Write-Host "
    PASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORD
    PASS                                                                                        WORD" -ForegroundColor Blue
Write-Host "   ----------------------------------->        $($newPass)        <-----------------------------------"
Write-Host "    PASS                                                                                        WORD
    PASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORDPASSWORD" -ForegroundColor Blue
        }catch{
            Write-Host $_ -ForegroundColor Red
            Write-Host "Password Reset... FAILED" -ForegroundColor DarkRed
        }
    }
}
function CrossCounterEditAll {
    Do {
        Write-Host "`n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" -ForegroundColor DarkRed
        Write-Host " - WARNING - " -ForegroundColor Red
        Write-Host "EDITING ** ALL ** USERS IN TENANT" -ForegroundColor Yellow
        Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" -ForegroundColor DarkRed
        Write-Host "`n
[1.] Company Name            $($User.CompanyName)
[2.] Department               $($User.Department)
[3.] Street address           $($User.StreetAddress)
[4.] City                     $($User.City)
[5.] Postal Code              $($User.PostalCode)
[6.] Country                 $($User.Country)
"
        $chosenOption = Read-Host -Prompt "What would you like to change? (Input Number, or 'q' to go back)"
        switch ($chosenOption) {
            1 {
                $i = 0
                $editMade = Read-Host -Prompt "Change company name for ALL users to"
                Do{
                    Try{
                        $User = $userList[($i)]
                        $userID = $User.ID
                        Update-MgUser -UserId $userID -CompanyName $editMade
                        Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated" -ForegroundColor DarkGreen
                    }Catch{
                        Write-Host "$($i). ERROR" -ForegroundColor Red
                    }
                    $i++
                }Until($i -ge ($userCount))
            Break 
            }
            2 {
                $i = 0
                $editMade = Read-Host -Prompt "Change ALL users' Department to"
                Do{
                    Try{
                        $User = $userList[($i)]
                        $userID = $User.ID
                        Update-MgUser -UserId $userID -Department $editMade
                        Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"  -ForegroundColor DarkGreen
                    }Catch{
                        Write-Host "$($i). ERROR" -ForegroundColor Red
                    }
                    $i++
                }Until($i -ge ($userCount))
            Break
            }
            3 {
                $i = 0
                $editMade = Read-Host -Prompt "Change ALL users' Street Address to"
                Do{
                    Try{
                        $User = $userList[($i)]
                        $userID = $User.ID
                        Update-MgUser -UserId $userID -StreetAddress $editMade
                        Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"  -ForegroundColor DarkGreen
                    }Catch{
                        Write-Host "$($i). ERROR" -ForegroundColor Red
                    }
                    $i++
                }Until($i -ge ($userCount))
            Break
            }
            4 {
                $i = 0
                $editMade = Read-Host -Prompt "Change ALL users' City to"
                Do{
                    Try{
                        $User = $userList[($i)]
                        $userID = $User.ID
                        Update-MgUser -UserId $userID -City $editMade
                        Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"  -ForegroundColor DarkGreen
                    }Catch{
                        Write-Host "$($i). ERROR" -ForegroundColor Red
                    }
                    $i++
                }Until($i -ge ($userCount))
            Break
            }
            5 {
                $i = 0
                $editMade = Read-Host -Prompt "Change ALL users' Postal Code to"
                Do{
                    Try{
                        $User = $userList[($i)]
                        $userID = $User.ID
                        Update-MgUser -UserId $userID -PostalCode $editMade
                        Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"  -ForegroundColor DarkGreen
                    }Catch{
                        Write-Host "$($i). ERROR" -ForegroundColor Red
                    }
                    $i++
                }Until($i -ge ($userCount))
            Break
            }
            6 {
                $i = 0
                $editMade = Read-Host -Prompt "Change ALL users' Country to"
                Do{
                    Try{
                        $User = $userList[($i)]
                        $userID = $User.ID
                        Update-MgUser -UserId $userID -Country $editMade
                        Write-Host "$($i+1). editing $($userList[$i].DisplayName) - Updated"  -ForegroundColor DarkGreen
                    }Catch{
                        Write-Host "$($i). ERROR" -ForegroundColor Red
                    }
                    $i++
                }Until($i -ge ($userCount))
            Break
            }
        }
    } Until ($chosenOption -eq 'q')
}

#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#
Write-Host "Connecting... Sign into the popup window with your admin account."  -ForegroundColor Green
Write-Host "..."
# Login to Microsoft Admin with AAD Read/Write Permissions
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","RoleManagement.ReadWrite.Directory","GroupMember.ReadWrite.All","Directory.ReadWrite.All","Directory.ReadWrite.All","UserAuthenticationMethod.ReadWrite.All","Calendars.ReadWrite.Shared"
Write-Host "`n`n" -ForegroundColor Green
#
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#----------------------------------------------------------------------------------
#                           FIRST STARTUP
#----------------------------------------------------------------------------------
# List all the users in the tenant
$userList = CrossCounterListUsers

# MAIN MENU ++++++++++++++++++++++++++++++++++++++++++++++++++++++|
Do {
    $User = ""
    $userID = ""
    $userInput1 = Read-Host -Prompt "
|----------------------------------------------------------------|
|                           MAIN MENU                            |
|   Enter the number listed next to the user you wish to edit    |
|   all    - edit ALL users in tenant                            |
|   groups - list groups in tenant                               |
|   users  - re-list users                                       |
|   q      - sign out & exit                                     |
|----------------------------------------------------------------|`n"
    switch ($userInput1) {

#If you type 'all' as the user ID, then we want to edit *all* of the users in the tenancy at once.
        'all' {
            CrossCounterEditAll
        Break
        }

        'groups' {
            Do {
                $groupList = CrossCounterListGroups
                $chosenGroup = Read-Host -Prompt "
|================================================================|
|                          GROUPS MENU                           |
|      Enter the number listed next to the group to edit it      |
| q         - go back                                            |
|================================================================|`n"
                #Try {
                    if(($chosenGroup -ne 'q') -and ($chosenGroup -ne '')){
                        $groupSelected = $groupList[$chosenGroup-1]
                        $groupID = $groupSelected.ID
                        if($groupSelected){
                            Do{
                                $groupSelected = Get-MgGroup -GroupId $groupID
                                $memberList = CrossCounterListMembers -GroupId $groupID
                                $chosenOption = Read-Host -Prompt "
|=============================================================================================|
|                                   MEMBERS MENU                                              |
| Enter the number listed next to the '$($groupSelected.DisplayName)' member to edit that user
| add       - Add a user to this group                                                        |
| remove    - Remove a user from this group                                                   |
| q         - go back                                                                         |
|=============================================================================================|`n"
                                switch($chosenOption){

                                    'q' {
                                        Break
                                    }

                                    'add' {
                                        CrossCounterAddMember -groupID $groupID
                                        Break
                                    }

                                    'remove' {
                                        CrossCounterRemoveMember -GroupId $groupID
                                        Break
                                    }

                                    default{
                                        Try {
                                            $member = $memberList[$chosenOption-1]
                                            Write-Host $member.DisplayName
                                            CrossCounterEditUser -userID $member.ID
                                        } Catch {
                                            Write-Host "Invalid Input - No member listed under that"   -ForegroundColor Red
                                        }
                                    }
                                }
                            }Until($chosenOption -eq 'q')
                        }
                    }
                # } Catch {
                #     Write-Host "Invalid Input - No group listed under that"
                # }
                }Until($chosenGroup -eq 'q')
                Break
        }

#Input 'users' to re-list all the users in the tenant
        'users' {
            $userList = CrossCounterListUsers
        Break
        }

# q to exit
        'q' {
            Write-Host "Signing out and exiting..."
            Disconnect-MgGraph
            exit
        }
# catch for blank input
        "" {
            Write-Host "Please input something..."   -ForegroundColor Red
            break
        }

#If a recognised keyword isn't input, check if it was the number of a user in the userlist
        default {
            $User = $userList[($userInput1-1)]
            $userID = $User.ID
            Try {
                $userList = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
                $User = Get-MgUser -UserId $userID
                CrossCounterEditUser -userID $userID
            } Catch {
                Write-Host "Invalid Input - Enter one of the menu commands...`n"  -ForegroundColor Red
            }
        }
    }
#If 'q' is entered instead of a user ID... We outta here
}Until(($userInput1-eq 'q'))
# 
# If we've made it out of the Do{}Until() loops somehow- then disconnect and exit gracefully.
#
Write-Host "Signing out and exiting..."
Disconnect-MgGraph
exit
#########################################################################################################################################
#
#
#
#                                                           NOTHING BELOW THIS LINE
##########################################################################################################################################