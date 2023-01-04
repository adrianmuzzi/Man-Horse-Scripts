<#
.SYNOPSIS
Edit user email property in graph.

.PARAMETER groupID
The ObjectID of the user you want to edit
#>
    param (
        [string]$userID
    )

    Do {
        $User = Get-MgUser -UserId $userID
        Write-Host "=================================================================================================" -ForegroundColor DarkYellow
        Write-Host "Editing $($User.DisplayName)    $($User.Mail)" -ForegroundColor Yellow
        Write-Host "=================================================================================================" -ForegroundColor DarkYellow
        $blocklist = Get-Mguser -Filter "accountEnabled eq false" #check if account is sign-in blocked
        if($blocklist.Id.Contains($userID)){
            Write-Host "USER ACCOUNT IS DISABLED" -ForegroundColor Red
            $accountEnabled = $false
        }else{
            $accountEnabled = $true
        }
        Write-Host @"
[1.] Edit User Profile
[2.] Reset User Password
[3.] TAP Into User Account
[4.] Enable/Disable Account Sign-in
[5.] Off Board User
[Q.] Go back
"@ -ForegroundColor Yellow

        $editUserMenu = Read-Host
        switch ($editUserMenu) {
            1 { 
                Do {
                    $User = Get-MgUser -UserId $userID
        <# 
        Certain attributes like 'CompanyName' and 'PostalCode' can only be called va Select-Object... and even then
        there appears to be a bug where some properties refuse to display correctly. As a result- not all Properties in this list
        show a 'preview'; you have to take the script at its word.
        Also, edits take a few moments to tick-over, so while it may appear like changes are not being made- be assured that they are. 
        #>
        Write-Host @"

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
"@ -ForegroundColor Yellow
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
                                    Write-Host "Success - New email is: $($editMade)" -ForegroundColor Green
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

                    }
                }Until($chosenOption -eq 'q')
                Break
            }
            2 {  #Edit password
                CrossCounterEditUserPassword -userID $userID
                Break
            }
            3 { #TAP Account
                Write-Host "Tapping Account..." -ForegroundColor DarkBlue
                Try{
                    $TAP = New-MgUserAuthenticationTemporaryAccessPassMethod -UserID $UserID -IsUsableOnce -LifetimeInMinutes 60
                    Write-Host "Your TAP is useable once in the next 60 minutes." -ForegroundColor DarkBlue
                    Write-Host "$($User.Mail)"
                    Write-Host "$($TAP.TemporaryAccessPass)" -ForegroundColor Cyan
                    Set-Clipboard -Value "$($TAP.TemporaryAccessPass)"
                    Write-Host "Copied to Clipboard." -ForegroundColor Blue
                    Start-Process msedge.exe -ArgumentList "-inprivate https://portal.office.com/"
                }Catch{
                    $errorCatch = $Error[0]
                    Write-Host $errorCatch -ForegroundColor Red
                    Write-Host "If you did not receive a TAP above, then one was not generated for you." -ForegroundColor Red
                }
                Write-Host
                Break 
            }
            4{ #enable/disable account sign-in
                if($accountEnabled){
                    Write-Host "Disabling account..." -ForegroundColor DarkYellow
                    Update-MgUser -UserID $userID -AccountEnabled:$false
                }else{
                    Write-Host "Re-enabling account..." -ForegroundColor DarkYellow
                    Update-MgUser -UserID $userID -AccountEnabled:$true
                }
                Break
            }
            5{ #OFF-BOARD USER
                Write-Host @"
|================================================================|
|                     OFF BOARD USER                             |
|================================================================|
"@ -ForegroundColor Yellow
                Write-Host "`nPlease note: the Graph API does not support Exchange admin actions.`nCrossCounter will pop a sign-in window for Exchange online." -ForegroundColor Yellow
                Write-Host "Are you sure you want to offboard $($User.DisplayName)? (y/n)" -ForegroundColor DarkYellow
                $confirm = Read-Host
                Try {
                    if ($confirm.toLower() -eq "y" ){
                        if(-not (Get-Module ExchangeOnlineManagement -ListAvailable)){
                            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
                            Write-Host "`nLooks like you don't have the required module.`nAllow one moment to install (first time set-up)..." -ForegroundColor DarkRed
                            Install-Module ExchangeOnlineManagement -Scope CurrentUser
                        }
                        Connect-ExchangeOnline -ShowBanner:$false
                        . $CrossCounterOffboard -UserID $userID
                    }
                }Catch{
                    Write-Host $_
                    Write-Host "Error - Off boarding failed to complete properly" -ForegroundColor Red
                }
                Break
            }
            "q" {
                Break
            }
            Default {
                Write-Host "Invalid Input - Please select a menu option, or 'q' to go back." -ForegroundColor Red
            }
        }
    }Until($editUserMenu -eq "q")