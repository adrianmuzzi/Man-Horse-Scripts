<#
    .SYNOPSIS
    Searches the registry for Edge profiles, and matches their name to their 'Profile #' folder
#>

$regProfiles = reg query HKEY_CURRENT_USER\Software\Microsoft\Edge\Profiles /s /v ShortcutName
#regProfiles[0] is a blank line and $regprofiles[$regprofiles.count-1] is "End of search: x match(es) found."
$i = 1
$outputData = ""
Do {
    if($i -gt 1) {$outputData += "`n"}
    $pName = $regprofiles[$i].replace("HKEY_CURRENT_USER\Software\Microsoft\Edge\Profiles\","")
    $nName = $regProfiles[$i+1].replace("    ShortcutName    REG_SZ    ","")
    $outputData += "$($pName)=$($nName)"
    $i+=3
} Until ($i -ge $regprofiles.count-1)
    Write-Host "Writing file..." -ForegroundColor DarkGray
    $outputData | Out-File -FilePath "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt" # Outputs to a txt file
    $outFile = ConvertFrom-StringData -StringData $outputData
    return $outFile
