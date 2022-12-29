Start-Transcript C:\MDM\DuaisValidation.log
Write-Host @"
 _____              _     
|  __ \            ( )     
| |  | |_   _  __ _ _ ___ 
| |  | | | | |/ _  | / __|
| |__| | |_| | (_| | \__ \
|_____/ \__,_|\__,_|_|___/
    (DETECTION SCRIPT)
"@ -ForegroundColor DarkCyan


$FileLocation =     #Full Path of the file you are changing
$FileHash =         #Hash of the file you want to end up with

$hash = Get-FileHash -Path $FileLocation

if ($hash -eq $FileHash) {
    Write-Host "Huzzah. File validated."
    Stop-Transcript 
    exit 0
} else {
    Write-Host "Something went wrong. File hash doesn't match."
    Stop-Transcript 
    exit 1
}
