<# Barclay McClay - 2022 #>
Write-Host "_______  _______  _                 _______  _                 ______   _______          
(       )(  ___  )( \      |\     /|(  ____ \| \    /\|\     /|(  __  \ (  ___  )|\     /|
| () () || (   ) || (      | )   ( || (    \/|  \  / /( \   / )| (  \  )| (   ) |( \   / )
| || || || (___) || |      | |   | || |      |  (_/ /  \ (_) / | |   ) || (___) | \ (_) / 
| |(_)| ||  ___  || |      | |   | || |      |   _ (    \   /  | |   | ||  ___  |  \   /  
| |   | || (   ) || |      | |   | || |      |  ( \ \    ) (   | |   ) || (   ) |   ) (   
| )   ( || )   ( || (____/\| (___) || (____/\|  /  \ \   | |   | (__/  )| )   ( |   | |   
|/     \||/     \|(_______/(_______)(_______/|_/    \/   \_/   (______/ |/     \|   \_/   " -ForegroundColor Blue
Write-Host "-- -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ --`n" -ForegroundColor DarkBlue
#################################################################################
if(-not (Get-Module ExchangeOnlineManagement -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module -Name ExchangeOnlineManagement
}
#================================================================================

function MaluckyDayListUsers {
    Write-Host "
          ___  ___  __   __
    |  | /__' |__  |__) /__' 
    \__/ .__/ |___ |  \ .__/ 
----------------------------------------------------------------------------------" -ForegroundColor DarkGreen
    $uL = Get-Mailbox | Sort-Object -Property Name
    $i = 0
    Do{
        Write-Host "$($i+1). $($uL[$i].DisplayName)       --- ---       $($uL[$i].UserPrincipalName)"
        $i++
    }Until($i -ge ($uL.count))
    Write-Host "`n$($uL.count) mailboxes - Listed alphabetically by display name" -ForegroundColor DarkGray
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console" -ForegroundColor DarkGray
    return $uL
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
            Default {
                Write-Host "Please input either 'q' - or a number listed above." -ForegroundColor Red

            }
        }
    }Until($chosenOption -eq 'q')
}

#================================================================================

Write-Host "Connecting... Sign into the popup window with your admin account."  -ForegroundColor Green
Write-Host "..."
# Login to Exchange Admin with AAD Read/Write Permissions
Connect-ExchangeOnline
Write-Host "`n" -ForegroundColor Green

#----------------------------------------------------------------------------------
#                           FIRST STARTUP
#----------------------------------------------------------------------------------
# List all the Mailboxes in the tenant
$userList = MaluckyDayListUsers


# MAIN MENU ++++++++++++++++++++++++++++++++++++++++++++++++++++++|
Do {
    $User = ""
    $userID = ""
    $userInput1 = Read-Host -Prompt "
|----------------------------------------------------------------|
|                           MAIN MENU                            |
|   Enter the number listed next to the user you wish to edit    |
|   q      - sign out & exit                                     |
|----------------------------------------------------------------|`n"
    switch ($userInput1) {
        "q"{
            break
        }
        "" {
            Write-Host "Please input something..."   -ForegroundColor Red
            break
        }
        default {
            $User = $userList[($userInput1-1)]
            $userID = $User.id
            Try {
                $userList = Get-Mailbox -Id
                $User = Get-MgUser -UserId $userID
                MaluckyDayEditUser -userID $userID
            } Catch {
                Write-Host "Invalid Input - Enter one of the menu commands...`n"  -ForegroundColor Red
            }
        }
    }
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