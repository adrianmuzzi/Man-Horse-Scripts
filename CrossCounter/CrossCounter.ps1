<# Barclay McClay - 2022 #>
Write-Host " __   __   __   __   __      __   __            ___  ___  __  " -ForegroundColor Yellow
Write-Host "/  ' |__) /  \ /__' /__'    /  ' /  \ |  | |\ |  |  |__  |__) " -ForegroundColor Yellow
Write-Host "\__, |  \ \__/ .__/ .__/    \__, \__/ \__/ | \|  |  |___ |  \ " -ForegroundColor Yellow
Write-Host "-- -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- " -ForegroundColor DarkYellow
#################################################################################
#Check if we have the Microsoft Graph Powershell Module, If we don't; Install it
if(-not (Get-Module Microsoft.Graph -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module Microsoft.Graph -Scope CurrentUser
}
if(-not (Get-Module pax8-api -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module -Name 'Pax8-API' -Scope CurrentUser
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
function GeneratePassword($PWStrength) {

    $n = Get-Random -Maximum 1000
    $word = @((Get-MnemonicWord) , (Get-MnemonicWord) , (Get-MnemonicWord)  , (Get-MnemonicWord)  , (Get-MnemonicWord) , (Get-MnemonicWord))
    $i=0
    Do{
        $pass += $word[$i].substring(0,1).toupper()+$word[$i].substring(1).tolower()
        $pass += "-"
        $i++
    }Until(($i -ge $PWStrength) -or ($i -ge 5))
        $pass += "$($n)"
    return $pass
}

$CrossCounterSkuToProduct = "$($PSScriptRoot)\CC-SkuToProduct.ps1"

$CrossCounterMatchPax8Tenant = "$($PSScriptRoot)\CC-MatchPax8Tenant.ps1"

$CrossCounterListUsers = "$($PSScriptRoot)\CC-ListUsers.ps1"

$CrossCounterListGroups = "$($PSScriptRoot)\CC-ListGroups.ps1"

$CrossCounterListMembers = "$($PSScriptRoot)\CC-ListMembers.ps1"

$CrossCounterOffboard = "$($PSScriptRoot)\CC-Offboard.ps1"

$CrossCounterAddMember = "$($PSScriptRoot)\CC-AddMember.ps1"

$CrossCounterRemoveMember = "$($PSScriptRoot)\CC-RemoveMember.ps1"

$CrossCounterEditUser = "$($PSScriptRoot)\CC-EditUser.ps1"

$CrossCounterEditUserMail = "$($PSScriptRoot)\CC-EditUserMail.ps1"

$CrossCounterEditUserPassword = "$($PSScriptRoot)\CC-EditUserPassword.ps1"

$CrossCounterEditAll ="$($PSScriptRoot)\CC-EditAll.ps1" 

function CrossCounterSearch ($search){
    Write-host "Searching users for $($search)..." -ForegroundColor Yellow
    $result = $userList.DisplayName.ToLower() | ForEach-Object { if($_.contains($search.ToLower())){$_} }
    Try {
        if($result.count -gt 1){
            Write-host "CrossCounter Found $($result.count) results containing '$($search)', please refine your search..." -ForegroundColor Yellow
            $i=0
            Do {
                Write-Host "    - $($result[$i])" -ForegroundColor DarkYellow
                $i++
            }Until($i -ge $result.count)
        }else{
            if($userList.DisplayName.ToLower() -match ($result.ToLower())){
                return $userList | Where-Object { $_.DisplayName.ToLower() -match $result.ToLower()}
            }else{
                return "No profile was found with that name..."
            }
        }   
    } Catch {
        return "Error - No profile"
    }
}

#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#
Write-Host "Connecting... Sign into the popup window with your admin account."  -ForegroundColor Green
# Login to Microsoft Admin with AAD Read/Write Permissions
Connect-MgGraph -Scopes "Organization.ReadWrite.All","User.ReadWrite.All","Group.ReadWrite.All","RoleManagement.ReadWrite.Directory","GroupMember.ReadWrite.All","Directory.ReadWrite.All","Directory.ReadWrite.All","Policy.Read.All","Policy.ReadWrite.AuthenticationMethod","UserAuthenticationMethod.ReadWrite.All","Calendars.ReadWrite.Shared"
#Get the Tenant ID
$tenantID = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/organization" 
$tenantID = $tenantID.Value
$tenantName =  $tenantID.displayName
$tenantID = $tenantID.id
Write-Host "CrossCounter has sucessfully integrated with $($tenantName)" -ForegroundColor Green
#
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================

#----------------------------------------------------------------------------------
#                           FIRST STARTUP
#----------------------------------------------------------------------------------
# List all the users in the tenant
Write-Host @"
==================================================================
$($tenantName) Users
==================================================================`n
"@ -ForegroundColor Yellow
    $userList = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
    $i = 0
    Do{
        Write-Host "$($i+1). $($userList[$i].DisplayName) - $($userList[$i].Mail)"
        $i++
    }Until($i -ge ($userCount))
    Write-Host "`n$userCount users - Listed alphabetically by display name" -ForegroundColor DarkGray
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console" -ForegroundColor DarkGray

# MAIN MENU ++++++++++++++++++++++++++++++++++++++++++++++++++++++|
Do {
    $User = ""
    $userID = ""
    Write-Host @"
|----------------------------------------------------------------|
|                           MAIN MENU                            |
|   Enter the number listed next to the user you wish to edit    |
|   all    - edit ALL users in tenant                            |
|   groups - list groups in tenant                               |
|   new    - on board new user                                   |
|   users  - re-list users                                       |
|   q      - sign out & exit                                     |
|----------------------------------------------------------------|
"@ -ForegroundColor Yellow
    $userInput1 = Read-Host
    switch ($userInput1) {

#If you type 'all' as the user ID, then we want to edit *all* of the users in the tenancy at once.
        'all' {
            . $CrossCounterEditAll
        Break
        }

        'groups' {
            Do {
                $groupList = . $CrossCounterListGroups
                Write-Host @"
|================================================================|
|                          GROUPS MENU                           |
|      Enter the number listed next to the group to edit it      |
| q         - go back                                            |
|================================================================|
"@ -ForegroundColor Yellow
                $chosenGroup = Read-Host
                    if(($chosenGroup -ne 'q') -and ($chosenGroup -ne '')){
                        $groupSelected = $groupList[$chosenGroup-1]
                        $groupID = $groupSelected.ID
                        if($groupSelected){
                            Do{
                                $groupSelected = Get-MgGroup -GroupId $groupID
                                $memberList = . $CrossCounterListMembers -GroupId $groupID
                                Write-Host @"
|=============================================================================================|
|                                   MEMBERS MENU                                              |
| Enter the number listed next to the '$($groupSelected.DisplayName)' member to edit that user
| add       - Add a user to this group                                                        |
| remove    - Remove a user from this group                                                   |
| q         - go back                                                                         |
|=============================================================================================|
"@ -ForegroundColor Yellow
                                $chosenOption = Read-Host
                                switch($chosenOption){

                                    'q' {
                                        Break
                                    }

                                    'add' {
                                        . $CrossCounterAddMember -groupID $groupID
                                        Break
                                    }

                                    'remove' {
                                        . $CrossCounterRemoveMember -GroupId $groupID
                                        Break
                                    }

                                    default{
                                        Try {
                                            $member = $memberList[$chosenOption-1]
                                            Write-Host $member.DisplayName
                                            . $CrossCounterEditUser -userID $member.ID
                                        } Catch {
                                            Write-Host "Invalid Input - No member listed under that"   -ForegroundColor Red
                                        }
                                    }
                                }
                            }Until($chosenOption -eq 'q')
                        }
                    }
                }Until($chosenGroup -eq 'q')
                Break
        }
#'new' to create new user
        'new' {
            Do {
                Write-Host @"
|================================================================|
|                        NEW USER MENU                           |
|   This feature is currently under development... sorry!        |
|   q         - go back                                          |
|================================================================|
"@ -ForegroundColor Red
                $newUserOpt = Read-Host
                switch($newUserOpt){
                    'q' {
                        Break
                    }
                }
            }Until($newUserOpt = 'q')
        }
#Input 'users' to re-list all the users in the tenant
        'users' {
           $userList = . $CrossCounterListUsers
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
            Try {
                if(($userList.count -ge $userInput1)-and($userInput1 -gt 0)){
                    $userList = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
                    $User = $userList[($userInput1-1)]
                    $userID = $User.ID
                    . $CrossCounterEditUser -userID $userID
                }else{
                    Write-Host "Please input an option listed in the menu."   -ForegroundColor Red
                }
            } Catch {
                $searchedProfile = CrossCounterSearch -search $userInput1
                if($searchedProfile -in $userList){
                    $User = $searchedProfile
                    $userID = $User.ID
                    . $CrossCounterEditUser -userID $userID
                }else{
                    Write-Host $searchedProfile -ForegroundColor Red
                }
            }      
        }
    }
#If 'q' is entered instead of a user ID... We outta here
}Until($userInput1 -eq 'q')
# 
# If we've made it out of the Do{}Until() loops somehow- then disconnect and exit gracefully.
#
Write-Host "Signing out and exiting..."
Disconnect-MgGraph
exit
#########################################################################################################################################
#VS Code shows these variables as "assigned but never used" because they only appear in dot referenced scripts and not this main index.
#This impossible if statement appears to call the variables so that VS code doesn't show the error (just comment it out and you'll see what I mean)
if(1 -ge 2){
    $CrossCounterOffboard
    $CrossCounterEditUserMail
    $CrossCounterEditUserPassword
    $CrossCounterSkuToProduct
    $CrossCounterMatchPax8Tenant
}
#########################################################################################################################################
#
#
#
#                                                           NOTHING BELOW THIS LINE
##########################################################################################################################################