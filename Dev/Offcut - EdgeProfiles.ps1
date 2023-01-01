<#This is a terrible way of nicknaming Edge profiles. 
But it does make for a good template when it comes to making an Outfile out of a mixture of user input and itereative elements.
#>


function AcrasiaManualSetup {
    $profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data" | Select-Object Name | Where-Object name -like '*Profile *' 
    if($profileList.count -gt 0){
        $i = 0
        $outputData = ""
        Do {
            if($i -gt 0) {$outputData += "`n"}
            Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"$($profileList[$i].name)`"  https://office.com"
            $add = Read-Host -Prompt "Name for $($profileList[$i].name)?"
            $outputData += "$($profileList[$i].name)=$($add)"
            $i++
        }Until($i -ge $profileList.count)
    }
    Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"Default`""
    $add = Read-Host -Prompt "Name for default profile?"
    $outputData += "`nDefault=$($add)"
    #create file
    $outputData | Out-File -FilePath "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\_AcrasiaData.txt"
    $outFile = ConvertFrom-StringData -StringData $outputData
    return $outFile
}