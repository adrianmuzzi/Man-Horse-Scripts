<# Barclay McClay - 2022 #>
Write-Host "_______  _______  _                 _______  _                 ______   _______          
(       )(  ___  )( \      |\     /|(  ____ \| \    /\|\     /|(  __  \ (  ___  )|\     /|
| () () || (   ) || (      | )   ( || (    \/|  \  / /( \   / )| (  \  )| (   ) |( \   / )
| || || || (___) || |      | |   | || |      |  (_/ /  \ (_) / | |   ) || (___) | \ (_) / 
| |(_)| ||  ___  || |      | |   | || |      |   _ (    \   /  | |   | ||  ___  |  \   /  
| |   | || (   ) || |      | |   | || |      |  ( \ \    ) (   | |   ) || (   ) |   ) (   
| )   ( || )   ( || (____/\| (___) || (____/\|  /  \ \   | |   | (__/  )| )   ( |   | |   
|/     \||/     \|(_______/(_______)(_______/|_/    \/   \_/   (______/ |/     \|   \_/   `n" -ForegroundColor Blue
Write-Host "-- -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ --" -ForegroundColor DarkBlue
#################################################################################
if(-not (Get-Module ExchangeOnlineManagement -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module -Name ExchangeOnlineManagement
}
#================================================================================

function MaluckyDayListUsers {
    Write-Host "`n----------------------------------------------------------------------------------
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
    Write-Host "`n$userCount mailboxes - Listed alphabetically by display name" -ForegroundColor DarkGray
    Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console" -ForegroundColor DarkGray
    return $uL
}


#================================================================================

Write-Host "Connecting... Sign into the popup window with your admin account."  -ForegroundColor Green
Write-Host "..."
# Login to Exchange Admin with AAD Read/Write Permissions
Connect-ExchangeOnline
Write-Host "`n`n" -ForegroundColor Green

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

#If you type 'all' as the user ID, then we want to edit *all* of the users in the tenancy at once.
        'all' {
            CrossCounterEditAll
        Break
        }
        "" {
            Write-Host "Please input something..."   -ForegroundColor Red
            break
        }
        default {
            $User = $userList[($userInput1-1)]
            $userID = $User.ID
            Try {
                $userList = Get-Mailbox -Id
                $User = Get-MgUser -UserId $userID
                CrossCounterEditUser -userID $userID
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