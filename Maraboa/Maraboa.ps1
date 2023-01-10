###

##
Write-Host @"
,---.    ,---.   ____    .-------.       ____     _______       ,-----.       ____     
|    \  /    | .'  __ `. |  _ _   \    .'  __ `. \  ____  \   .'  .-,  '.   .'  __ `.  
|  ,  \/  ,  |/   '  \  \| ( ' )  |   /   '  \  \| |    \ |  / ,-.|  \ _ \ /   '  \  \ 
|  |\_   /|  ||___|  /  ||(_ o _) /   |___|  /  || |____/ / ;  \  '_ /  | :|___|  /  | 
|  _( )_/ |  |   _.-`   || (_,_).' __    _.-`   ||   _ _ '. |  _`,/ \ _/  |   _.-`   | 
| (_ o _) |  |.'   _    ||  |\ \  |  |.'   _    ||  ( ' )  \: (  '\_/ \   ;.'   _    | 
|  (_,_)  |  ||  _( )_  ||  | \ `'   /|  _( )_  || (_{;}_) | \ `"/  \  ) / |  _( )_  | 
|  |      |  |\ (_ o _) /|  |  \    / \ (_ o _) /|  (_,_)  /  '. \_/``".'  \ (_ o _) / 
'--'      '--' '.(_,_).' ''-'   `'-'   '.(_,_).' /_______.'     '-----'     '.(_,_).'  
"@ -ForegroundColor Magenta
Write-Host "=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=" -ForegroundColor DarkRed
##
if(-not (Get-Module HaloAPI -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`n(First time set-up)..." -ForegroundColor DarkRed
    Install-Module HaloAPI -Scope CurrentUser
}
##

$MaraboaDateSelect = "$($PSScriptRoot)\Mara-DateSelect.ps1"

##
Connect-HaloAPI -URL 
##
Do {
    Write-Host @"
[D] Date Select
[?] Display help
[Q] Quit
"@ -ForeGroundColor Cyan
$opt1 = Read-Host
switch ($opt1) {
    '?'{
        Write-Host @"
Use-case/Guide: 

Maraboa is named for the 1935 Melbourne Cup Winner;
It is a script for scraping data from the HaloPSA API.
"@
        break
    }
    'd' {
        $dateStart = . $MaraboaDateSelect
        $dateEnd = . $MaraboaDateSelect
        $tickets = Get-HaloTicket -StartDate $dateStart -EndDate $dateEnd
        Write-Host "There were $($tickets.count) tickets from $($dateStart) to $($dateEnd)"
        break
    }
    'q'
    {
        break
    }
    default {
        Write-Host "- Invalid Input -" -ForegroundColor Red
    }

    }
}Until ($opt1 -eq 'q')
# 
# If we've made it out of the Do{}Until() loops somehow- then exit gracefully.
#
Write-Host "Exiting..."
exit
#########################################################################################################################################
#
#
#
#                                                           NOTHING BELOW THIS LINE
##########################################################################################################################################