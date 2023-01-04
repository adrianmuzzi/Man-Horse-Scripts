
    <#
    .SYNOPSIS
    Edit user password with graph

    .PARAMETER userID
    The ObjectID of the user you want to edit
    #>

    param (
        $userID
    )
    #Reset Password
    Write-Host "-----------------------------" -ForegroundColor DarkBlue
    Write-Host " Reset Password..." -ForegroundColor Blue
    Write-Host "-----------------------------`n" -ForegroundColor DarkBlue
    Do{
        $genPass = @( (GeneratePassword -PWStrength 1) , (GeneratePassword -PWStrength 2) , (GeneratePassword -PWStrength 3) ,(GeneratePassword -PWStrength 4) , (GeneratePassword -PWStrength 5) )
        $i=0
        Do{
            Write-Host "[$($i+1).] $($genPass[$i])" -ForegroundColor Cyan
            $i++
        }Until($i -ge 5)
        Write-Host "[C.] Custom Input" -ForegroundColor DarkCyan
        Write-Host "[R.] Re-Shuffle Choices" -ForegroundColor DarkCyan
        Write-Host "[Q.] Go Back (No Change)" -ForegroundColor Gray
        $resetPasswordMenu = Read-Host
        switch ($resetPasswordMenu) {
            "c" { 
                Write-Host @"
Passwords must be 8+ characters long; cannot contain the user's ID; and have at least 3 of the following: 
Upper-case letter, lower-case letter, number, symbol.
"@ -ForegroundColor Cyan
                $customPass = Read-Host -Prompt "Input desired password"
                if($customPass.Length -ge 8){
                    $newPass = $customPass
                }
             }
            "r" { 
                Break
             }
            "q" { 
                Break 
            }
            {$_ -ge 1 -and $_ -le 5} {
                $newPass = $genPass[$resetPasswordMenu-1]
                Break
            }
            Default {
                Write-Host "Invalid Input - Please make a choice above, or 'q' to go back without changing the password." -ForegroundColor Red
              }
        }
        if($newPass){
            Try {
                Write-Host "Resetting password to $($newPass)" -ForegroundColor Blue
                #$authMethod = Get-MgUserAuthenticationMethod -UserId $userID
                Reset-MgUserAuthenticationMethodPassword -UserId $userID -AuthenticationMethodId "28c10230-6103-485e-b985-444c60001490" -NewPassword $newPass
                Write-Host "   ------>        $($newPass)        <------" -ForegroundColor Cyan
                Set-Clipboard -Value $newPass
                Write-Host "Copied to clipboard." -ForegroundColor Blue
                $resetPasswordMenu = 'q'
            }Catch{
                Write-Host $_ -ForegroundColor Red
                Write-Host "Password Reset FAILED" -ForegroundColor DarkRed
            }
        }
    }Until($resetPasswordMenu -eq "q")