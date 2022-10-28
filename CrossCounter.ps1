<# Barclay McClay - 2022 - ver1.1 #>
Write-Host " __   __   __   __   __      __   __            ___  ___  __  "
Write-Host "/  ' |__) /  \ /__' /__'    /  ' /  \ |  | |\ |  |  |__  |__) "
Write-Host "\__, |  \ \__/ .__/ .__/    \__, \__/ \__/ | \|  |  |___ |  \ "
Write-Host "                                                              "
Write-Host "-- -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ --`n"
#################################################################################

#Check if we have the Microsoft Graph Powershell Module, If we don't; Install it
if(-not (Get-Module Microsoft.Graph -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..."
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module Microsoft.Graph -Scope CurrentUser
}

# ==============================================================================
#                             DEFINE FUNCTIONS
# ==============================================================================
function GeneratePassword {
    $num1 = Get-Random -Maximum 10000
    $word1 = "Happy","Ability","Exact","Coral","Core","Cello","Correct","Play","Vegetable","Couch","Country","Couple","Course","SOUP","cover","Stable","Shoe" | Get-Random
    $letterList = "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","!","?","$","1","2","3","4","5","6","7","8","9"
    $passArr = $num1, $word1, ($letterList | Get-Random), ($letterList | Get-Random),($letterList | Get-Random),($letterList | Get-Random)| Get-Random -Shuffle
    $newPassword = [String]::Join("",$passArr)
    return $newPassword
}

function CrossCounterListUsers {
    Write-Host "`n----------------------------------------------------------------------------------
          ___  ___  __   __
    |  | /__' |__  |__) /__' 
    \__/ .__/ |___ |  \ .__/ 
----------------------------------------------------------------------------------"
    $uL = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
    $i = 0
    Do{
        Write-Host "$($i+1). $($uL[$i].DisplayName)       --- ---       $($uL[$i].Mail)"
        $i++
    }Until($i -eq ($userCount))
    Write-Host "`n$userCount users - Listed alphabetically by display name"
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console"
    return $uL
}

function CrossCounterListGroups {
    Write-Host "`n"
    Write-Host "===============================================================================                                                            
     __   __   __        __   __  
    / _' |__) /  \ |  | |__) /__' 
    \__> |  \ \__/ \__/ |    .__/ "
    Write-Host "================================================================================"
    Write-Host "`n"
    $i = 0
    $gL = Get-MgGroup -All -Count groupCount -ConsistencyLevel eventual -OrderBy DisplayName
    Do{
        Write-Host "$($i+1). $($gL[$i].DisplayName) --- $($gL[$i].Description)"
        $i++
    }Until($i -eq ($groupCount))
    Write-Host "`n$groupCount groups - Listed alphabetically"
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console"
    return $gL
}

function CrossCounterListMembers {
    param (
        $GroupId
    )
    Write-Host "================================================================================================="
    Write-Host "Editing $($groupSelected.DisplayName)"
    Write-Host "(Note changes may take a minute or two to cache)"
    Write-Host "=================================================================================================`n"
    $i = 0
    #This gets an array that only contains the user IDs of the group members (as well as other inconsequential info)
    $mIdL = Get-MgGroupMember -GroupId $GroupId -Count memberCount -ConsistencyLevel eventual
    $mL = [Object[]]::new($memberCount)
    #First we convert these extracted userIds into user objects
    Do {
        $mL[$i] = (Get-MgUser -UserId ($mIdL[$i].Id))
        $i++
    } Until($i -eq $memberCount)
    #now we re-arrange the array of user objects alphabetically by display name
    $mL = $mL | Sort-Object -Property @{Expression = "DisplayName"}
    $i = 0
    #and write the alphabetical list of users
    Do{
        Write-Host "$($i+1). $(($mL[$i]).DisplayName)"
        $i++
    }Until($i -eq ($memberCount))
    Write-Host "`n$memberCount members of $($groupSelected.DisplayName) - Listed alphabetically..."
    return $mL
}

function CrossCounterEditUser {
    param (
        $userID
    )
    Do {
        $User = Get-MgUser -UserId $userID
        Write-Host "================================================================================================="
        Write-Host "Editing $($User.DisplayName)"
        Write-Host "(Note changes may take a minute or two to cache, only options 1-5 preview in this window)"
        Write-Host "================================================================================================="
<# 
There appears to be a bug?? where attributes like 'CompanyName' and 'PostalCode' cannot be called in the same way as 
'DisplayName, GivenName, MobilePhone, etc.
Also, edits take a few moments to tick-over, so while it may appear like changes are not being made- be assured that they are. 
#>
        Write-Host "`n
[1.] Display Name             $($User.DisplayName)
[2.] First Name               $($User.GivenName)
[3.] Last Name                $($User.Surname)
[4.] Job Title                $($User.JobTitle)
[5.] Mobile Phone             $($User.MobilePhone)
[6.] Department               $($User.Department)
[7.] Street address           $($User.StreetAddress)
[8.] City                     $($User.City)
[9.] Postal Code              $($User.PostalCode)
[10.] Country                 $($User.Country)
[11.] Company Name            $($User.CompanyName)
[12.] Remove from Group
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
                Update-MgUser -UserId $userID -GivenName $editMade; Break
            }
            3 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.Surname)' to?"
                Update-MgUser -UserId $userID -Surname $editMade; Break
            }
            4 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.JobTitle)' to?"
                Update-MgUser -UserId $userID -JobTitle $editMade; Break
            }
            5 {
                $editMade = Read-Host -Prompt "What would you like to change '$($User.MobilePhone)' to?"
                Update-MgUser -UserId $userID -MobilePhone $editMade; Break
            }
            6 {
                $editMade = Read-Host -Prompt "What would you like to change the department to?"
                Update-MgUser -UserId $userID -Department $editMade; Break
            }
            7 {
                $editMade = Read-Host -Prompt "What would you like to change the street address to?"
                Update-MgUser -UserId $userID -StreetAddress $editMade; Break
            }
            8 {
                $editMade = Read-Host -Prompt "What would you like to change the city to?"
                Update-MgUser -UserId $userID -City $editMade; Break
            }
            9 {
                $editMade = Read-Host -Prompt "What would you like to change postal code to?"
                Update-MgUser -UserId $userID -PostalCode $editMade; Break
            }
            10 {
                $editMade = Read-Host -Prompt "What would you like to change the Country to?"
                Update-MgUser -UserId $userID -Country $editMade; Break
            }
            11 {
                $editMade = Read-Host -Prompt "What would you like to change the company name to?"
                Update-MgUser -UserId $userID -CompanyName $editMade; Break
            }
            12 {

            }
        }
    }Until($chosenOption -eq 'q')
}

#================================================================================

Write-Host "Connecting... Sign into the popup window with your admin account."
Write-Host "..."
# Login to Microsoft Admin with AAD Read/Write Permissions
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All","UserAuthenticationMethod.ReadWrite.All"
Write-Host ".`n..`n...`n....`n.....`n....`n...`n..`n."

#----------------------------------------------------------------------------------
# List all the users in the tenant

$userList = CrossCounterListUsers

# Prompt for ID of user
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
|   off    - User Offboarding                                    |
|   q      - sign out & exit                                     |
|----------------------------------------------------------------|`n"

    switch ($userInput1) {

#If you type 'all' as the user ID, then we want to edit *all* of the users in the tenancy at once.
        'all' {
            Do {
                Write-Host "`n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
                Write-Host " - WARNING - "
                Write-Host "EDITING ** ALL ** USERS IN TENANT"
                Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
                Write-Host "`n
[1.] Company Name            $($User.CompanyName)`n
[2.] Department               $($User.Department)`n
[3.] Street address           $($User.StreetAddress)`n
[4.] City                     $($User.City)`n
[5.] Postal Code              $($User.PostalCode)`n
[6.] Country                 $($User.Country)`n
"
                $chosenOption = Read-Host -Prompt "What would you like to change? (Input Number, or 'q' to go back)"
                switch ($chosenOption) {
                    1 {
                        $i = 0
                        $editMade = Read-Host -Prompt "Change company name for ALL users to"
                        Do{
                            $User = $userList[($i)]
                            $userID = $User.ID
                            Update-MgUser -UserId $userID -CompanyName $editMade
                            Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"
                            $i++
                        }Until($i -eq ($userCount))
                    Break 
                    }
                    2 {
                        $i = 0
                        $editMade = Read-Host -Prompt "Change ALL users' Department to"
                        Do{
                            $User = $userList[($i)]
                            $userID = $User.ID
                            Update-MgUser -UserId $userID -Department $editMade
                            Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"
                            $i++
                        }Until($i -eq ($userCount))
                    Break
                    }
                    3 {
                        $i = 0
                        $editMade = Read-Host -Prompt "Change ALL users' Street Address to"
                        Do{
                            $User = $userList[($i)]
                            $userID = $User.ID
                            Update-MgUser -UserId $userID -StreetAddress $editMade
                            Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"
                            $i++
                        }Until($i -eq ($userCount))
                    Break
                    }
                    4 {
                        $i = 0
                        $editMade = Read-Host -Prompt "Change ALL users' City to"
                        Do{
                            $User = $userList[($i)]
                            $userID = $User.ID
                            Update-MgUser -UserId $userID -City $editMade
                            Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"
                            $i++
                        }Until($i -eq ($userCount))
                    Break
                    }
                    5 {
                        $i = 0
                        $editMade = Read-Host -Prompt "Change ALL users' Postal Code to"
                        Do{
                            $User = $userList[($i)]
                            $userID = $User.ID
                            Update-MgUser -UserId $userID -PostalCode $editMade
                            Write-Host "$($i+1). $($userList[$i].DisplayName) - Updated"
                            $i++
                        }Until($i -eq ($userCount))
                    Break
                    }
                    6 {
                        $i = 0
                        $editMade = Read-Host -Prompt "Change ALL users' Country to"
                        Do{
                            $User = $userList[($i)]
                            $userID = $User.ID
                            Update-MgUser -UserId $userID -Country $editMade
                            Write-Host "$($i+1). editing $($userList[$i].DisplayName) - Updated"
                            $i++
                        }Until($i -eq ($userCount))
                    Break
                    }
                }
            } Until ($chosenOption -eq 'q')
        Break
        }

        'groups' {
            Do {
                $groupList = CrossCounterListGroups
                $chosenOption = Read-Host -Prompt "
|================================================================|
|                          GROUPS MENU                           |
| Enter the number listed next to the group to edit it           |
| new       - Create a new group                                 |
| q         - go back                                            |
|================================================================|`n"
                Try {
                    if(($chosenOption -ne 'new') -and ($chosenOption -ne 'q')){
                        $groupSelected = $groupList[$chosenOption-1]
                        $groupID = $groupSelected.ID
                        Do{
                            $memberList = CrossCounterListMembers -GroupId $groupID
                            $chosenOption = Read-Host -Prompt "
|=============================================================================================|
|                                   GROUP MENU                                                |
| Enter the number listed next to the $($groupSelected.DisplayName) member to edit that user  |
| add       - Add a user to this group                                                        |
| remove    - Remove a user from this group                                                   |
| q         - go back                                                                         |
|=============================================================================================|`n"
                            switch($chosenOption){

                                'q' {
                                    Break
                                }

                                'add' {
                                    $userList = CrossCounterListUsers
                                    Do {
                                        $chosenUser = Read-Host -Prompt "`nEnter the number listed next to the user you want to add to the '$($groupSelected.DisplayName)' group (or 'q' to go back)`n"
                                        Try {
                                            if ($chosenUser -ne 'q'){
                                                $member = $userList[$chosenUser-1]
                                                Write-Host "Adding $($member.DisplayName) to $($groupSelected.DisplayName)..."
                                                Try {
                                                    New-MgGroupMember -GroupId $groupID -DirectoryObjectId $member.ID
                                                    Write-Host "SUCCESS! Added $($member.DisplayName) to $($groupSelected.DisplayName)"
                                                }Catch{
                                                    Write-Host "FAILED to add $($member.DisplayName) to $($groupSelected.DisplayName)"
                                                }
                                                $chosenUser = 'q'
                                            }
                                        } Catch {
                                            Write-Host "Invalid Input - No member listed under that"
                                        }
                                    } Until ($chosenUser -eq 'q')
                                    Break
                                }

                                'remove' {

                                    Break
                                }

                                default{
                                    Try {
                                        $member = $memberList[$chosenOption-1]
                                        Write-Host $member.DisplayName
                                        CrossCounterEditUser -userID $member.ID
                                    } Catch {
                                        Write-Host "Invalid Input - No member listed under that"
                                    }
                                }
                            }
                        }Until($chosenOption -eq 'q')
                    }
                } Catch {
                    Write-Host "Invalid Input - No group listed under that"
                }
                
            
            }Until($chosenOption -eq 'q')
            Break
        }
#=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-=
#'off' for User offboarding
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
                        Write-Host "2. - REMOVING FROM GROUPS"
                            # need this for the graph query below; it needs a $ref tacked on at the end. By setting the variable to '$ref' it does not get interpreted as a variable.
                            $ref = "$ref" #janky!!
                            Invoke-MgGraphRequest -Method Delete -Uri "https://graph.microsoft.com/v1.0/groups/$($GroupObj.Id)/members/$($userID)/$ref"
                    }
                }else{
                        Write-Host "Invalid Input - Enter the number listed next to the user"
                }
            } Until ($chosenOption = 'q')
        Break
        }
#=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-=

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

        "" {
            Write-Host "Please input something..."
            break
        }

#If a recognised keyword isn't input, check if it was the number of a user in the userlist
        default {
            $User = $userList[($userInput1-1)]
            $userID = $User.ID
            Try {
                $userList = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
                $User = Get-MgUser -UserId $userID
            } Catch {
                Write-Host "Invalid Input - No user found listed under that number..."
                Write-Host ""
            }
            # Only show the next menu if requested user exists
            if ($User) {
                CrossCounterEditUser -userID $userID
            }else{
                Write-Host "`nInvalid Input - Choose a number`n"
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
