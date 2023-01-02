<# Barclay McClay - 2022 #>
#This script is for creating new users.
Write-Host "......................." -ForegroundColor DarkMagenta
Write-Host @"
█ █ █ █▀█ ▀█▀ ▄▀█ █▄ █
▀▄▀▄▀ █▄█  █  █▀█ █ ▀█
"@ -ForegroundColor Magenta
Write-Host "......................." -ForegroundColor DarkMagenta

#################################################################################
#Check if we have the Microsoft Graph Powershell Module, If we don't; Install it
if(-not (Get-Module Microsoft.Graph -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module Microsoft.Graph -Scope CurrentUser
}

function WotanNew ($Template) {
    Write-Host "`n......................." -ForegroundColor DarkMagenta
    Write-Host "New User Creation" -ForegroundColor Magenta
    Write-Host ".......................`n" -ForegroundColor DarkMagenta

    if($Template){
    Write-Host "Using default values taken from $($Template.DisplayName)"
        $CompanyName = $Template.CompanyName
        $City = $Template.City
        $OfficeLocation = $Template.OfficeLocation
        $PostalCode = $Template.PostalCode
        $BusinessPhones = $Template.BusinessPhones
        $State = $Template.State
    }
$outputData = @"
UserPrincipalName=
GivenName=
Surname=
BusinessPhones=$($BusinessPhones)
City=$($City)
State=$($State)
OfficeLocation=$($OfficeLocation)
CompanyName=$($CompanyName)
PostalCode=$($PostalCode)
Department=
JobTitle=
Mail=
MobilePhone=
PasswordProfile=
UsageLocation=AU
"@
    #create file
    $outputData | Out-File -FilePath "C:\temp\WotanUser.txt"
    Write-Host "Press <ENTER> to open a txt file. Enter the new user's profile details into this txt file, save & close; then press enter again when ready."
    Read-Host
    & "C:\temp\WotanUser.txt"
    Read-Host
    Write-Host Get-Content -Path "C:\temp\WotanUser.txt" | Out-String | ConvertFrom-StringData
}

function WotanListUsers {
    Write-Host "......................." -ForegroundColor DarkMagenta
    Write-Host "        USERS          " -ForegroundColor Magenta
    Write-Host "......................." -ForegroundColor DarkMagenta
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

function WotanSearch ($search){
    Write-host "Searching users for $($search)..." -ForegroundColor Magenta
    $result = $userList.DisplayName.ToLower() | ForEach-Object { if($_.contains($search.ToLower())){$_} }
    Try {
        if($result.count -gt 1){
            Write-host "Wotan Found $($result.count) results containing '$($search)', please refine your search..." -ForegroundColor Magenta
            $i=0
            Do {
                Write-Host "    - $($result[$i])" -ForegroundColor DarkMagenta
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
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","RoleManagement.ReadWrite.Directory","GroupMember.ReadWrite.All","Directory.ReadWrite.All","Directory.ReadWrite.All","Policy.Read.All","Policy.ReadWrite.AuthenticationMethod","UserAuthenticationMethod.ReadWrite.All","Calendars.ReadWrite.Shared"
#
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================

#Lets take a random user
$userList = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
$templateUser = $userList[(get-random -min 0 -max $userList.count)]
Do{ 
    Write-Host "Copy some default values from $($templateUser.DisplayName)? (You will have the option to change these)" -ForegroundColor Magenta
    Write-Host @"
    [1] - Yes, use $($templateUser.DisplayName) as a template.
    [2] - No, don't copy anyone. Create this user totally from scratch.
    [3] - I want to copy a different user...
    [Q] - Quit
"@ -ForegroundColor Magenta
    $menuChoice = Read-Host
    switch ($menuChoice) {
        1 { 
            WotanNew -Template $templateUser
        }
        2 { 
            WotanNew -Template $null
        }
        3 { 
            $templateUser = $null
            Do{
                $userList = WotanListUsers
                Write-Host "Input the number listed next to the user you wish to use as a template. You can also enter the desired user's name." -ForegroundColor Magenta
                Write-Host "(or 'q' to go back)" -ForegroundColor Magenta
                $userInput1 = Read-Host
                switch ($userInput1) {
                    'q' { break }
                    default {
                        Try {
                            if(($userList.count -ge $userInput1)-and($userInput1 -gt 0)){
                                $userList = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName
                                $templateUser = $userList[($userInput1-1)]
                                WotanNew -Template $templateUser
                            }else{
                                Write-Host "Please input a valid number, or 'q' to go back."   -ForegroundColor Red
                            }
                        } Catch {
                            $searchedProfile = WotanSearch -search $userInput1
                            if($searchedProfile -in $userList){
                                $templateUser = $searchedProfile
                                WotanNew -Template $templateUser
                            }else{
                                Write-Host $searchedProfile -ForegroundColor Red
                            }
                        }      
                    }
                }
            }Until($templateUser -or $userInput1 -eq "q")
            break;
        }
        "q" { 
            break 
        }
        Default {
            Write-Host "Invalid Input - Please input a number from the menu above, or 'q' to quit."
        }
    }
}Until($menuChoice -eq 'q')
#########################################################################################################################################
exit
#########################################################################################################################################
#
#
#
<#                                                           NOTHING BELOW THIS LINE
##########################################################################################################################################


$outTxt = @"
GivenName=
Surname=
BusinessPhones=
City=
CompanyName=
Department=
JobTitle=
Mail=
MobilePhone=
OfficeLocation=
PasswordProfile=
PostalCode=
State=
UsageLocation=
UserPrincipalName=
"@
#>