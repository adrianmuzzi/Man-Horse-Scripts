<# Barclay McClay - 2022 - ver1.0 #>
Write-Host "
 _____              _     
|  __ \            (_)    
| |  | |_   _  __ _ _ ___ 
| |  | | | | |/ _` | / __|
| |__| | |_| | (_| | \__ \
|_____/ \__,_|\__,_|_|___/

" -ForegroundColor DarkCyan
Write-Host "Connecting... Sign into the popup window with your admin account.`n..." -ForegroundColor DarkGreen
# Login to Microsoft Admin with AAD Read/Write Permissions
Connect-MgGraph -Scopes "User.Read.All"
Do {
$master = Read-Host -Prompt "`n
'?' Display help
'q' Quit
'Otherwise, enter the 'master' domain- this is the email domain Duais will use copy profile information FROM;`n(enter EVERYTHING AFTER the '@' symbol - do not include '@')`n'"
switch ($master) {
    '?'
    {
        Write-Host "
        Use-case/Guide: You have a tenant where people are controlling multiple email accounts.
        You need users' profile information copied accross from their 'master' account to their other, 'slave' account.
        
        !! Note that Duais does this operation EN-MASSE to the WHOLE tenant; THIS IS NOT A TOOL FOR EDITING A 'SINGLE' USER AT A TIME !!
        
        First, you will enter the 'master' domain- this is the email domain we will use copy information FROM;
        Next, you enter the 'slave' domain- this is the email we will copy information TO;
        Then, you choose the primary 'common' element that Duais will look for when trying to match up a user's profile.
        Finally, you are given the option of a secondary element for Duais to use when matching profiles"    
        break
    }
    'q'
    {
        break
    }
    default {
        $master = $master.Insert(0, '@')
        $mL = Get-MgUser -All -Count userCount -ConsistencyLevel eventual -Filter "endsWith(Mail, $master)" 
        Write-Host $mL.Length
        $i = 0
        Do {
            if(($mL[$i].subStr($mL[$i].Length - $master.Length, $master.Length)) -eq $master){
                $masterCount++
            }
            $i++
        }Until($i -ge $userCount)
    }

    }
}Until ($master -eq 'q')