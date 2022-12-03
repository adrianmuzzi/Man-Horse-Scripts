<# Barclay McClay - 2022 - ver0.1 #>
Write-Host "
 _____              _     
|  __ \            (_)    
| |  | |_   _  __ _ _ ___ 
| |  | | | | |/ _` | / __|
| |__| | |_| | (_| | \__ \
|_____/ \__,_|\__,_|_|___/

" -ForegroundColor DarkCyan

Do {
    Write-Host @"
[?] Display help
[Q] Quit
"@ -ForeGroundColor Cyan
$opt1 = Read-Host
switch ($opt1) {
    '?'{
        Write-Host @"
Use-case/Guide: 
"@
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