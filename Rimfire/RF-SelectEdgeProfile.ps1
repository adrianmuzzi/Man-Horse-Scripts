function AcrasiaStart {
    $profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data" | Select-Object Name | Where-Object name -like '*Profile *'
    if(Test-Path -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -PathType Leaf){ #Do we have _AcrasiaData.txt file?
        Write-Host "Previous Acrasia data vaildated..." -ForegroundColor DarkGray #We have found a file...
        $AcrasiaProfiles = Get-Content -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" | Out-String 
        $AcrasiaProfiles = ConvertFrom-StringData -StringData $AcrasiaProfiles   #Read the data
        $AcrasiaProfiles = $AcrasiaProfiles.GetEnumerator() | Sort-Object -Property Value
        if($AcrasiaProfiles.count -ne ($profileList.count+1)){
            Write-Host "Acrasia has detected changes in your Edge profiles since last setup." -ForegroundColor Yellow
            Write-Host "There are $($profileList.count+1) Edge Profiles, but Acrasia has $($AcrasiaProfiles.count) in its records." -ForegroundColor Yellow
            Write-Host "Re-syncing $($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -ForegroundColor DarkGray
            $AcrasiaProfiles = . $ACSetup
        }
    }else{
        Write-Host "It looks like you do not have any Acrasia Data..." -ForegroundColor Yellow
        Write-Host "Creating file at: $($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" -ForegroundColor DarkGray
        $AcrasiaProfiles = . $ACSetup
    }
    return $AcrasiaProfiles
}

function AcrasiaSelect {
    $i = 0
    Do{
        Write-Host "$($i+1). $($AcrasiaProfiles[$i].value)" -ForegroundColor Blue
        $i++
    }Until($i -ge $AcrasiaProfiles.count)
    Write-Host "Select which Edge profile to use for $($selectedTicket.client_name) admin actions (enter a number, or 'q' to cancel)" -ForegroundColor Yellow
    $prompt = Read-Host
    switch ($prompt) {
        'q' { 
            Write-Host "Action cancelled." -ForegroundColor Red
            Stop-Transcript
            exit
         }
        Default {
            Try {
                if(($AcrasiaProfiles.count -ge $prompt)-and($prompt -gt 0)){
                    Write-Host($AcrasiaProfiles[$prompt-1].name + "-" + $AcrasiaProfiles[$prompt-1].value + " selected...") -ForegroundColor Yellow
                    return $prompt-1
                }else{
                    Write-Host "Enter a number between 1 and $($AcrasiaProfiles.count)" -ForegroundColor Red
                }
            }Catch{
                Write-Host "Enter a number between 1 and $($AcrasiaProfiles.count)" -ForegroundColor Red
            }
        }
    }
}


########################################################
Write-Host "Starting Acrasia..." -ForegroundColor Blue
$AcrasiaProfiles = AcrasiaStart
$len = 1
Do {
    $searchFor = $selectedTicket.client_name.SubString(0 , $len)
    $EdgeProfile = $AcrasiaProfiles.value -match $searchFor
    $len++
}Until(($len -gt $selectedTicket.client_name.Length) -or (($EdgeProfile.count -eq 1) -and ($EdgeProfile)))
if($EdgeProfile.count -lt 1){
    Write-Host "Could not match Halo client to Edge profile name..." -ForegroundColor DarkRed
    $EdgeProfile = AcrasiaSelect
}
#We finally have the desired Edge profile...
if($EdgeProfile){
    $EdgeProfileFolder = $AcrasiaProfiles | Where-Object Value -eq $EdgeProfile
    Write-Host "Using Edge Profile: $EdgeProfile ($EdgeProfileFolder)" -ForegroundColor DarkGray
    return $EdgeProfileFolder
}else{
    Write-Host "There was an error selecting an Edge profile for this action. Aborting..." -ForegroundColor Red
    Stop-Transcript
    exit
}