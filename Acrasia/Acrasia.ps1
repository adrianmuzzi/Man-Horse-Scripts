<#Barclay McClay - 0.1 - 2022 #>
Write-Host "
█████████████████████████████████████████
██▀▄─██─▄▄▄─█▄─▄▄▀██▀▄─██─▄▄▄▄█▄─▄██▀▄─██
██─▀─██─███▀██─▄─▄██─▀─██▄▄▄▄─██─███─▀─██
▀▄▄▀▄▄▀▄▄▄▄▄▀▄▄▀▄▄▀▄▄▀▄▄▀▄▄▄▄▄▀▄▄▄▀▄▄▀▄▄▀" -ForegroundColor Green
Write-Host "=========================================`n" -ForegroundColor DarkGreen

$profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data" | Select-Object Name | Where-Object name -like *"Profile "*
Write-Host "$($profileList.count + 1) Edge Profiles detected"

function AcrasiaSetup {
    Write-Host "An Edge Browser window will pop up. Note which profile it is for, and input your name for it into Acrasia..."
    $i = 0
    $outputData = ""
    Do {
        if($i -gt 0) {$outputData += "`n"}
        Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"$($profileList[$i].name)`""
        $add = Read-Host -Prompt "Name for $($profileList[$i].name)?"
        $outputData += "$($profileList[$i].name)=$($add)"
        $i++
    }Until($i -ge $profileList.count)
    Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"Default`""
    $add = Read-Host -Prompt "Name for default profile?"
    $outputData += "`nDefault=$($add)"
    #create file
    $outputData | Out-File -FilePath "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
    $outFile = ConvertFrom-StringData -StringData $outputData
    return $outFile
}

function AcrasiaListProfiles {
    param (
        $ACRASIA_LIST
    )
    $i = 0
    Do{
        Write-Host "$($i+1). $($($ACRASIA_LIST.Values)[$i])" -ForegroundColor Green
        $i++
    }Until($i -ge $ACRASIA_LIST.count)
}

function ArcasiaShortcuts {
    Do{
    Write-Host "    $($selectedName)            " -ForegroundColor Black -BackgroundColor Blue
    Write-Host "[1.] AAD" -ForegroundColor Green      #https://portal.azure.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/AllUsers
    Write-Host "[2.] M365 Admin Portal" -ForegroundColor Green    #https://portal.microsoft.com/Adminportal/Home#/users
    Write-Host "[3.] Exchange Admin Center" -ForegroundColor Green         #https://admin.exchange.microsoft.com/#/mailboxes
    Write-Host "[4.] MEM / Intune" -ForegroundColor Green   #https://endpoint.microsoft.com/#home
    Write-Host "[5.] MS Portals" -ForegroundColor Green     #https://msportals.io/?search=
    Write-Host "[Q.] <-Back`n" -ForegroundColor Gray
    $link = $false
    $sc = Read-Host
    switch ($sc){
        "q" { break }
        1   {$link = "https://portal.azure.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/AllUsers" }
        2   {$link = "https://portal.microsoft.com/Adminportal/Home#/users" }
        3   {$link = "https://admin.exchange.microsoft.com/#/mailboxes" }
        4   {$link = "https://endpoint.microsoft.com/#home" }
        5   {$link = "https://msportals.io/?search=" }
        Default {
            Write-Host "- Invalid Input - " -ForegroundColor Red
        }
    }
    if($link) {
        Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"$($selectedProfile)`" $($link)"
    }
    }Until(($sc -eq "q") -or ($sc -eq "Q"))
}

if(-not(Test-Path -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -PathType Leaf)){
    Write-Host "It looks like you do not have any Acrasia Data..." -ForegroundColor Red
    Write-Host "It will take <$((($profileList.count + 1)*8)/60)> minutes to run through a setup process wherein you will manually run through your Edge profiles with Acrasia."
    $setupOpt = Read-Host -Prompt "Run Setup? [y/n]"
    switch ($setupOpt){
        "y" {
            Write-Host "Edge stores profile information under generic directories called 'Profile 1', 'Profile 2'... and so on.`nAcrasia helps you create a labelled list of these Profile folders for easy access."
            $AcrasiaProfiles = AcrasiaSetup
        }
        Default {
            exit
        }
    }
}else{
    Write-Host "Previous Acrasia data detected..." -ForegroundColor Green
    $importData = Get-Content -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" | Out-String
    $AcrasiaProfiles = ConvertFrom-StringData -StringData $importData
}

AcrasiaListProfiles -ACRASIA_LIST $AcrasiaProfiles
    
Do{
    Write-Host "                         ACRASIA - MAIN MENU                      " -ForegroundColor Black -BackgroundColor Green
    Write-Host "|   Enter the number listed next to a profile above, or:         |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|   setup  - run through Acrasia setup again                     |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|   list   - list the profiles setup in Acrasia                  |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|   q      - quit                                                |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|----------------------------------------------------------------|`n" -ForegroundColor Green -BackgroundColor Black
    $opt1 = Read-Host
    switch ($opt1) {
        "list"  {
            AcrasiaListProfiles -ACRASIA_LIST $AcrasiaProfiles
            Break
        }
        "setup" {
            $profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data" | Select-Object Name | Where-Object name -like *"Profile "*
            Write-Host "$($profileList.count + 1) Edge Profiles detected"
            $AcrasiaProfiles = AcrasiaSetup
            break
        }
        "q"     {
            break
        }
        Default {
            if(($AcrasiaProfiles.count -ge $opt1)-and($opt1 -gt 0)){
                Try {
                    $selectedProfile = $($AcrasiaProfiles.keys)[$opt1-1]
                    $selectedName = $($AcrasiaProfiles.values)[$opt1-1]
                    ArcasiaShortcuts
                }Catch{
                    Write-Host "ERRCATCH - Invalid Input" -ForegroundColor Red
                } 
                Break
            }
        }
    }
}Until($opt1 -eq "q")
#we out of the main loop!
exit
##########################################
#                                        #
#               THE END                  #
#                                        #
##########################################