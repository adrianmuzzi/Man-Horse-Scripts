<#
    .SYNOPSIS
    Edit user email property in graph.

    .PARAMETER userID
    The ObjectID of the user you want to edit
#>
param (
    [string]$userID
)
$i = 0 
Do {
    $editMade = ""
    $User = Get-MgUser -UserId $userID      
    $mail = $User.Mail -Split "@"
    $fname = ($User.GivenName -replace '[\W]', '').ToLower() #sanitized for special characters
    $sname = ($User.Surname -replace '[\W]', '').ToLower()   #sanitized for special characters
    $mailOpt = "0","custom","no change","janesmith","jane.smith","jsmith","j.smith","janes","jane.s","js","j.s","smithj", "smith.j", "smithjane", "smith.jane"
    $i++
    $mailOpt[$i] = "";
    Write-Host "`n$($i). - Custom input -"
    $i++
    $mailOpt[$i] = "";
    Write-Host "`n$($i). - No Change -"
    $i++
    $mailOpt[$i] = "$($fname)$($sname)@$($mail[1])"        # janesmith@domain
    Write-Host "`n$($i). $($mailOpt[$i])"                 
    $i++
    $mailOpt[$i] = "$($fname).$($sname)@$($mail[1])"       # jane.smith@domain
    Write-Host "`n$($i). $($mailOpt[$i])"
    $i++
    $mailOpt[$i] = "$($fname.Substring(0,1))$($sname)@$($mail[1])"   # jsmith@domain
    Write-Host "`n$($i). $($mailOpt[$i])"
    $i++
    $mailOpt[$i] = "$($fname.Substring(0,1)).$($sname)@$($mail[1])"  # j.smith@domain
    Write-Host "`n$($i). $($mailOpt[$i])"  
    $i++ 
    $mailOpt[$i] = "$($fname)$($sname.Substring(0,1))@$($mail[1])"     # janes@domain
    Write-Host "`n$($i). $($mailOpt[$i])"
    $i++ 
    $mailOpt[$i] = "$($fname).$($sname.Substring(0,1))@$($mail[1])"     # jane.s@domain
    Write-Host "`n$($i). $($mailOpt[$i])"  
    $i++ 
    $mailOpt[$i] = "$($fname.Substring(0,1))$($sname.Substring(0,1))@$($mail[1])" # js@domain
    Write-Host "`n$($i). $($mailOpt[$i])" 
    $i++ 
    $mailOpt[$i] = "$($fname.Substring(0,1)).$($sname.Substring(0,1))@$($mail[1])" # j.s@domain
    Write-Host "`n$($i). $($mailOpt[$i])"
    $i++ 
    $mailOpt[$i] = "$($sname).$($fname.Substring(0,1))@$($mail[1])" # smithj@domain
    Write-Host "`n$($i). $($mailOpt[$i])" 
    $i++ 
    $mailOpt[$i] = "$($sname).$($fname.Substring(0,1))@$($mail[1])" # smith.j@domain
    Write-Host "`n$($i). $($mailOpt[$i])"
    $i++ 
    $mailOpt[$i] = "$($sname)$($fname)@$($mail[1])" # smithjane@domain
    Write-Host "`n$($i). $($mailOpt[$i])" 
    $i++ 
    $mailOpt[$i] = "$($sname).$($fname)@$($mail[1])" # smith.jane@domain
    Write-Host "`n$($i). $($mailOpt[$i])" 
    $editMade = Read-Host -Prompt "`nWhat would you like to change '$($User.Mail)' to? (Pick an option above)`n"

}Until($editMade -ne "")
switch ($editMade) {
    0 { 
        return ""
        Break
    }
    1 {
        Write-Host
        $custInput = Read-Host -Prompt "-CUSTOM-`nWhat would you like to change ____________$($mail[1]) to?`n"
        return $custInput+$mail[1]
        Break}
    2 {
        return ""
        Break
    }
    Default {
        return $mailOpt[$editMade]
    }
}
