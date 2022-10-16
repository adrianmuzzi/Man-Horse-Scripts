<# Barclay McClay - 2022#>
Write-Host " __   __   __   __   __      __   __            ___  ___  __  "
Write-Host "/   '|__) /  \ /__' /__'    /  ' /  \ |  | |\ |  |  |__  |__)"
Write-Host "\__, |  \ \__/ .__/ .__/    \__, \__/ \__/ | \|  |  |___ |  \ "
Write-Host "                                                              "
Write-Host "-- -- Make quick basic changes to Azure Active Directory -- --`n"
#Check if we have the Microsoft Graph Powershell Module, If we don't, Install it
if(-not (Get-Module Microsoft.Graph -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..."
    Write-Host "The system may ask you if you 'trust' this repository. Enter 'A' for 'Yes to All'."
    Install-Module Microsoft.Graph -Scope CurrentUser
}
Write-Host "Connecting... Sign into the popup window with your admin account."
Write-Host "..."
# Login to Microsoft Admin with AAD Read/Write Permissions
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All"
# List all the users in the tenant
Get-MgUser -All -Count userCount -ConsistencyLevel eventual -OrderBy DisplayName | Format-Table  ID, DisplayName, Mail
Write-Host "`n$userCount users - Listed alphabetically by display name"
Write-Host "Press < ALT + SPACE , E , F > to search within Powershell console`n"
# Prompt for ID of user
Do {
    $userID = Read-Host -Prompt "Input the Id (listed above) of the desired user (or 'q' to sign out and quit)`n"
    $User = Get-MgUser -UserId $userID
    # Only show the next menu if requested user exists
    if ($User) {
        Do {
            $User = Get-MgUser -UserId $userID
            Write-Host "==============================================================="
            Write-Host "Editing $($User.DisplayName)"
            Write-Host "(Note changes may take a minute or two to cache, options 5-11 do not show up in this window)"
            Write-Host "==============================================================="
            <# 
            There appears to be a bug?? where attributes like 'CompanyName' and 'PostalCode' cannot be called in the same way as 
            'DisplayName, GivenName, MobilePhone, etc.
            Also, edits take a few moments to tick-over, so while it may appear like changes are not being made- be assured that they are. 
            #>
            Write-Host "`n
                [1.] Display Name             $($User.DisplayName)`n
                [2.] First Name               $($User.GivenName)`n
                [3.] Last Name                $($User.Surname)`n
                [4.] Job Title                $($User.JobTitle)`n
                [5.] Mobile Phone             $($User.MobilePhone)`n
                [6.] Department               $($User.Department)`n
                [7.] Street address           $($User.StreetAddress)`n
                [8.] City                     $($User.City)`n
                [9.] Postal Code              $($User.PostalCode)`n
                [10.] Country                 $($User.Country)`n
                [11.] Company Name            $($User.CompanyName)`n"
            $chosenOption = Read-Host -Prompt "What would you like to change? (Input Number, or 'q' to go back)"
            switch ($chosenOption) {
                1 {
                    $editMade = Read-Host -Prompt "What would you like to change '$($User.DisplayName)' to?"
                    Update-MgUser -UserId $userID -DisplayName $editMade; Break
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
            }
        }Until($chosenOption -eq 'q')
    }
    else {
        Write-Host "`nNo user found with that ID.`n"
    }
#If 'q' is entered instead of a user ID... We outta here
}Until($userID -eq 'q')

#Sign out and quit.
if($userID -eq 'q'){
    Write-Host "Signing out and exiting..."
    Disconnect-MgGraph
    exit
}