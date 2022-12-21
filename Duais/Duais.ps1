<# Barclay McClay - 2022 - ver0.1 #>
#This script takes a file at a give filepath... renames it, then replaces it with another specified file.
#You need to configure the script manually by changing the variables up top here:

###################################################################################################################################################################################
#                                                                       CHANGES GO IN HERE
$NewFile =          #Full path of the new file
$TargetLocation =   #Path of the target file's parent folder
$TargetName =       #Filename of target file
#
####################################################################################################################################################################################

Start-Transcript C:\MDM\Duais.log -Force

Write-Host @"
 _____              _     
|  __ \            ( )     
| |  | |_   _  __ _ _ ___ 
| |  | | | | |/ _  | / __|
| |__| | |_| | (_| | \__ \
|_____/ \__,_|\__,_|_|___/

"@ -ForegroundColor DarkCyan

$FileHash = (Get-FileHash -Path $NewFile).Hash

Write-Host "Replacing: $($TargetName)"
Write-Host "In: $($TargetLocation)"
Write-Host "With the file: $($NewFile)"
Write-Host "Filehash: $($FileHash)"

Try {
    Write-Host "`n"
    Rename-Item -Path "$($TargetLocation)\$($TargetName)"-NewName "$($TargetName).bak" -Force -ErrorAction SilentlyContinue -ErrorVariable +ITEMERR
    Write-Host "Target backed up: $($TargetLocation)\$($TargetName)"
    Copy-Item -Path $NewFile -Destination $TargetLocation -ErrorVariable +ITEMERR -ErrorAction SilentlyContinue
    "Installed" | Out-File C:\MDM\Duais.ps1.tag
    if ((Get-FileHash -Path ($TargetLocation+"\"+$TargetName)).Hash -eq $FileHash) {
        Write-Host "Successfully installed at $($TargetLocation)\"
    } else {
        Write-Host "Failed to install at $($TargetLocation)\"
        Write-Host $ITEMERR   
    }
} Catch {
    Write-Error "Something went wrong."
}
Write-Host "`n"
Stop-Transcript


#########################################################################################################################################
#
#
#
#                                                           NOTHING BELOW THIS LINE
##########################################################################################################################################