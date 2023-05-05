<#Barclay McClay - 2022 #>
Write-Host @"
█████████████████████████████████████████
██▀▄─██─▄▄▄─█▄─▄▄▀██▀▄─██─▄▄▄▄█▄─▄██▀▄─██
██─▀─██─███▀██─▄─▄██─▀─██▄▄▄▄─██─███─▀─██
█▄▄█▄▄█▄▄▄▄▄█▄▄█▄▄█▄▄█▄▄█▄▄▄▄▄█▄▄▄█▄▄█▄▄█
"@ -ForegroundColor Green
Write-Host "=========================================`n" -ForegroundColor DarkGreen

$profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data" | Select-Object Name | Where-Object name -like '*Profile *'
Write-Host "$($profileList.count +1) Edge Profiles detected" -ForegroundColor Green

$CCScript = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent
$CCScript = $CCScript+"\CrossCounter\CrossCounter.ps1"

###########################################################################################################################################################################################

$AcrasiaSetup = "$($PSScriptRoot)\ACRASIA-Setup.ps1"

function AcrasiaRename ($renameProfile,$NewName) {
    $i = 0
    $str = ""
    Try{
        Do{
            if($AcrasiaProfiles[$i].Name -eq $renameProfile){
                $str += $AcrasiaProfiles[$i].Name
                $str += "="
                $str += $NewName
                $str += "`n"
            }else{
                $str += $AcrasiaProfiles[$i].Name
                $str += "="
                $str += $AcrasiaProfiles[$i].Value
                $str += "`n"
            }
            $i++
        }Until($i -ge $AcrasiaProfiles.count)
    }Catch{
        Write-Host -Prompt "An error has occurred while renaming $($renameProfile)... No data has been written." -ForegroundColor Red
        Read-Host -Prompt "Press enter to edit Acrasia data manually"
        & "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
        return
    }
    Try{
        $str | Out-File -FilePath "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
        $outFile = ConvertFrom-StringData -StringData $str
        $outFile = $outFile.GetEnumerator() | Sort-Object -Property Value
    }Catch{
        Write-Host -Prompt "An error has occurred while writing the new Acrasia data to file" -ForegroundColor Red
        Read-Host -Prompt "Press enter to edit Acrasia data manually"
        & "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
        return
    }
}

function AcrasiaListProfiles {
    $i = 0
    Do{
        Write-Host "$($i+1). $($AcrasiaProfiles[$i].value)" -ForegroundColor Green
        $i++
    }Until($i -ge $AcrasiaProfiles.count)
}

function AcrasiaRefreshProfiles {
    $AcrasiaProfiles = Get-Content -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" | Out-String  #Read the data
    $AcrasiaProfiles = ConvertFrom-StringData -StringData $AcrasiaProfiles 
    $AcrasiaProfiles = $AcrasiaProfiles.GetEnumerator() | Sort-Object -Property Value
    return $AcrasiaProfiles
}

function AcrasiaShortcuts {
    Do{
    Write-Host
    Write-Host "    $($selectedName)            " -ForegroundColor Black -BackgroundColor Green
    Write-Host "[1.] Azure Portal" -ForegroundColor Green      #https://portal.azure.com/
    Write-Host "[2.] M365 Admin Portal" -ForegroundColor Green    #https://portal.microsoft.com/Adminportal/Home#/users
    Write-Host "[3.] Exchange Admin Center" -ForegroundColor Green         #https://admin.exchange.microsoft.com/#/mailboxes
    Write-Host "[4.] MEM / Intune" -ForegroundColor Green   #https://endpoint.microsoft.com/#home
    Write-Host "[5.] Office 365 Portal" -ForegroundColor Green     #https://portal.office.com
    Write-Host "[6.] MS Portals" -ForegroundColor Green     #https://msportals.io/?search='
    Write-Host "[7.] Sharepoint Admin Center" -ForegroundColor Green     #https://admin.microsoft.com/sharepoint
    Write-Host "[B.] Profile Bookmarks" -ForegroundColor DarkGreen
    Write-Host "[C.] CrossCounter" -ForegroundColor DarkGreen
    Write-Host "[R.] Rename Profile" -ForegroundColor DarkGreen
    Write-Host "[Q.] Go Back`n" -ForegroundColor Gray
    $link = $false
    $sc = Read-Host
    switch ($sc){
        "q" { break }
        1   {$link = "https://portal.azure.com/" }
        2   {$link = "https://portal.microsoft.com/Adminportal/Home#/users" }
        3   {$link = "https://admin.exchange.microsoft.com/#/mailboxes" }
        4   {$link = "https://endpoint.microsoft.com/#home" }
        5   {$link = "https://portal.office.com" }
        6   {$link = "https://msportals.io/?search=" }
        7   {$link = "https://admin.microsoft.com/sharepoint" }
        "b" { #Bookmarks
            $bk = AcrasiaGetBookmarks -ProfileKey $selectedProfile
            $i=0
            Do{
                Write-Host "[$($i+1).] $($bk[$i] -replace 'https://','')" -ForegroundColor Green
                $i++
            }Until($i -ge $bk.count)
            Write-Host "[Q.] Go Back" -ForegroundColor Gray
            $bc = Read-Host
            switch ($bc) {
                Default {
                    if($bc -ne "q"){
                        Try{
                            $link = "$($bk[$bc-1])"
                        }Catch{
                            Write-Host "Invalid Input" -ForegroundColor Red
                        }
                    }
                }
            }
        }
        "c"{ #Cross Counter
            Try{
                if(Test-Path -Path $CCScript -PathType Leaf){
                    Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"$($selectedProfile)`" about:blank)"
                    Write-Host "Launching CrossCounter..." -ForegroundColor Green
                    .$CCScript
                }else{
                    Write-Host "CrossCounter is not present at the expected directory:`n$($CCScript)`n" -ForegroundColor DarkGray
                }
            }Catch{
                Write-Host $_ -ForegroundColor DarkRed
                Write-Host "An unexpected error has caused CrossCounter to fail..." -ForegroundColor Red
                $CCScript
            }
        }
        "r"{ #rename
            $NewName = Read-Host -Prompt "Rename $($selectedName) to"
            AcrasiaRename -renameProfile $selectedProfile -NewName $NewName
            $sc = "q"
            break
        }
        Default {
            Write-Host "- Invalid Input - " -ForegroundColor Red
        }
    }
    if($link) {
        Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"$($selectedProfile)`" $($link)"
    }
    }Until(($sc -eq "q") -or ($sc -eq "Q"))
}

function AcrasiaGetBookmarks {
    param(
        $profileKey
    )
    $bkmrk = Get-Content -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\$($profileKey)\Bookmarks.msbak" | ConvertFrom-Json
    return $bkmrk.roots.bookmark_bar.children.url
}

function AcrasiaSearch ($search){
    $result = $AcrasiaProfiles.value.ToLower() | ForEach-Object { if($_.contains($search.ToLower())){$_} }
    Try {
        if($result.count -gt 1){
            Write-host "Acrasia Found $($result.count) matches, please refine your search..." -ForegroundColor Yellow
            $i=0
            Do {
                Write-Host "    - $($result[$i])" -ForegroundColor DarkYellow
                $i++
            }Until($i -eq $result.count)
        }else{
            if($AcrasiaProfiles.value.ToLower().contains($result.ToLower())){
                return $AcrasiaProfiles | Where-Object { $_.Value.ToLower() -contains $result.ToLower()}
            }else{
                return "No profile was found with that name..."
            }
        }   
    } Catch {
        return "No profile was found with that name..."
    }
}

##############################################################################################################################################################################################

# IMPORTING ACRASIA PROFILES & FIRST TIME STARTUP
if(Test-Path -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -PathType Leaf){ #Do we have _AcrasiaData.txt file?
    Write-Host "Previous Acrasia data vaildated...`n=========================================" -ForegroundColor Green #We have found a file...
    $AcrasiaProfiles = Get-Content -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" | Out-String 
    $AcrasiaProfiles = ConvertFrom-StringData -StringData $AcrasiaProfiles   #Read the data
    $AcrasiaProfiles = $AcrasiaProfiles.GetEnumerator() | Sort-Object -Property Value
    if($AcrasiaProfiles.count -ne ($profileList.count+1)){
        Write-Host "Acrasia has detected changes in your Edge profiles since last setup." -ForegroundColor Yellow
        Write-Host "There are $($profileList.count+1) Edge Profiles, but Acrasia has $($AcrasiaProfiles.count) in its records." -ForegroundColor Yellow
        Write-Host "Re-syncing $($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -ForegroundColor DarkGray
        $AcrasiaProfiles = . $AcrasiaSetup
    }
}else{
    Write-Host "It looks like you do not have any Acrasia Data..." -ForegroundColor Yellow
    Write-Host "Creating file at: $($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -ForegroundColor DarkGray
    $AcrasiaProfiles = . $AcrasiaSetup
}
    
Do{
    $AcrasiaProfiles=AcrasiaRefreshProfiles
    AcrasiaListProfiles
    Write-Host "                        ACRASIA - MAIN MENU                       " -ForegroundColor Black -BackgroundColor Green
    Write-Host "|         Enter the number listed next to a profile above,       |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|        or enter the name (or partial name) of the profile      |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|   setup  - run through Acrasia setup again                     |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|   q      - quit                                                |" -ForegroundColor Green -BackgroundColor Black
    Write-Host "|________________________________________________________________|`n" -ForegroundColor Green -BackgroundColor Black
    $opt1 = Read-Host
    switch ($opt1) {
        "setup" {
            Write-Host "Re-syncing $($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -ForegroundColor DarkGray
            $AcrasiaProfiles = . $AcrasiaSetup
            Write-Host "Opening file..." -ForegroundColor DarkGray
            & "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
            break
        }
        "q"     {
            break
        }
        Default {
            Try {
                if(($AcrasiaProfiles.count -ge $opt1)-and($opt1 -gt 0)){
                    $selectedProfile = $AcrasiaProfiles[$opt1-1].name
                    $selectedName = $AcrasiaProfiles[$opt1-1].value
                    AcrasiaShortcuts
                    $AcrasiaProfiles=AcrasiaRefreshProfiles
                }else{
                    Write-Host "Enter a number between 1 and $($AcrasiaProfiles.count)" -ForegroundColor Red
                }
            }Catch{
                $searchedProfile = AcrasiaSearch -search $opt1
                if($searchedProfile -in $AcrasiaProfiles){
                    $selectedName = $searchedProfile.Value
                    $selectedProfile = $searchedProfile.Name
                    AcrasiaShortcuts
                    $AcrasiaProfiles=AcrasiaRefreshProfiles
                }else{
                    Write-Host $searchedProfile -ForegroundColor Red
                }
            }
            Break
        }
    }
}Until(($opt1-eq 'q') -or $opt1 -eq "devmode")
#we out of the main loop!
#if($opt1 -eq "devmode"){
#    & "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
    #nothing yet.. but we escaped the loop witout calling exit
#}else{
    exit
#}
##########################################
#                                        #
#               THE END                  #
#                                        #
##########################################