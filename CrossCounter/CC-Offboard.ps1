<#
    .SYNOPSIS
    Offboards a user

    .PARAMETER UserId
    The ObjectID of the user you want to offboard
#>
param (
    [string]$UserId
)

$User = Get-MgUser -UserId $UserID
$offboardlog = "Off boarding $($User.DisplayName)`n" #we'll use this to create a log of the off boarding

Write-Host "Set the mailbox's auto reply for 'internal' messages (enter to skip)" -ForegroundColor Yellow
$internalMsg = Read-Host

Write-Host "Set the mailbox's auto reply for 'external' messages (enter to skip)" -ForegroundColor Yellow
$externalMsg = Read-Host

#	1. Change M365 Password
Write-Host "Resetting password..." -ForegroundColor DarkYellow
Try{
    $newPass = GeneratePassword -PWStrength 4
    $authMethod = Get-MgUserAuthenticationMethod -UserId $userID
    Reset-MgUserAuthenticationMethodPassword -UserId $userID -AuthenticationMethodId $authMethod.Id -NewPassword $newPass
    $offboardlog += "`nUser password reset: $($newPass)"
}Catch{
    $offboardlog += $_
    $offboardlog += "`nPassword reset failed."
    Write-Host "Password reset failed (check the log)." -ForegroundColor Red
}
#    2. Convert account to Shared Mailbox
$exchangeUser = Get-Mailbox | Where-Object -Property ExternalDirectoryObjectId -eq $UserID
Write-Host "Converting to shared mailbox..." -ForegroundColor DarkYellow
Try{
    Set-Mailbox -Identity $exchangeUser -Type Shared
    $offboardlog += "`nConverted $($User.Mail) to shared mailbox."
}Catch{
    Write-Host $_
    Write-Host "Could not convert to shared mailbox." -ForegroundColor DarkRed
    $offboardlog += "`nCouldn't convert to shared mailbox."
}
#	3. Set Out of Office / Forwarding from shared mailbox
Write-Host "Configuring auto-reply message..." -ForegroundColor DarkYellow
if($internalMsg -eq "" -and $externalMsg -eq ""){
    $AutoReplyState = "Disabled"
}else{
    if($internalMsg -eq ""){
        $internalMsg = $externalMsg
    }else{
        if ($externalMsg -eq ""){
            $externalMsg = $internalMsg
    }}
    $AutoReplyState = "Enabled"
}
Set-MailboxAutoReplyConfiguration -Identity $exchangeUser -AutoReplyState $AutoReplyState -InternalMessage $internalMsg -ExternalMessage $externalMsg -ExternalAudience All
$offboardlog += "`nInternal auto reply set to:`n$($internalMsg)"
$offboardlog += "`nExternal auto reply set to:`n$($externalMsg)"
#	4. Remove user from Global Address List
Write-Host "Hiding from Global Address List..." -ForegroundColor DarkYellow
Set-Mailbox -Identity $exchangeUser -HiddenFromAddressListsEnabled $true
$offboardlog += "`nUser removed from Global Address List"

#	5. Remove from all M365 Groups
Write-Host "Removing from M365 groups..." -ForegroundColor DarkYellow
$groups = Get-MgUserMemberOf -UserID $userID -Count membershipCount -ConsistencyLevel eventual
$groups = $groups.id
if($groups.count -gt 1){
    $i=0
    Do{
        $groupId = $groups[$i]
        $groupName = (Get-MgGroup -GroupId $groupId).DisplayName
        if($groupName -ne "All Users"){
            Try{
                Write-Host "Removing from group - $($groupName)" -ForegroundColor DarkYellow
                $offboardlog += "`nRemoving from group - $($groupName)"
                Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $UserID 2> $null
            }Catch{
                Write-Host $_
                $offboardlog += "Error removing from group - $($groupName)"
                Write-Host "Graph API Cannot Update a group with dynamic membership, a mail-enabled security group, or a distribution list." -ForegroundColor DarkRed
            }
        }
        $i++
    }Until($i -ge $groups.count)
#   Now do the same for distro lists
    Write-Host "Removing from mail distribution groups..." -ForegroundColor DarkYellow
    $offboardlog += "`nRemoving from mail distribution groups..."
    $groups = Get-MgUserMemberOf -UserID $userID -Count membershipCount -ConsistencyLevel eventual
    $groups = $groups.id
    $i=0
    Do{
        Try{
            $distroGroup = Get-DistributionGroup | Where-Object ExternalDirectoryObjectId -eq $groups[$i]
            if($null -ne $distroGroup){
                Remove-DistributionGroupMember -Identity $distroGroup -Member $user.DisplayName -Confirm:$false
                Write-Host "Removing from $($distroGroup.name)"
                $offboardlog += "`n$($distroGroup.name)"
            }
        }Catch{
            Write-Host $_
            $offboardlog += "`nError detected while removing from group."
        }
        $i++
    }Until($i -ge $groups.count)
}else{
    Write-Host "User is only in 1 group - $((Get-MgGroup -GroupId $groups).DisplayName)" -ForegroundColor DarkYellow
    $offboardlog += "`nUser is only in 1 group - $((Get-MgGroup -GroupId $groups).DisplayName)"
}
#	6. Remove License on M365
    Write-Host "Removing user licenses..." -ForegroundColor DarkYellow
    Try{
    $license = Get-MgSubscribedSku -All | Where-Object AppliesTo -eq 'User'
    Set-MgUserLicense -UserId $UserID -AddLicenses @() -RemoveLicenses @($license.SkuId)
    $offboardlog += "Licenses removed"
    }Catch{
        Write-Host $_
        Write-Host "Error - Trouble removing user licenses." -ForegroundColor DarkRed
    }
#	7. Block Account on M365
Write-Host "Disabling account..." -ForegroundColor DarkYellow
Try{
    Update-MgUser -UserID $userID -AccountEnabled:$false
    Write-Host "Account sign-ins blocked. Off boarding complete.`n" -ForegroundColor DarkYellow
    $offboardlog += "`nAccount disabled. Off boarding completed."
}Catch{
    Write-Host $_
    Write-Host "Error - Could not disable user account.`n"
    $offboardlog += "`nCould not disable account.`nOff boarding completed."
}

$offboardlog += "`n$(Get-Date)"
$offboardlog | Out-File -FilePath "C:\Temp\OffboardedUser.log" #create the log