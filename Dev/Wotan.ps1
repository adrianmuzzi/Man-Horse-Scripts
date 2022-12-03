<# Transfers data from Chrome to Edge #>
Write-Host "......................." -ForegroundColor DarkMagenta
Write-Host @"
█ █ █ █▀█ ▀█▀ ▄▀█ █▄ █
▀▄▀▄▀ █▄█  █  █▀█ █ ▀█
"@ -ForegroundColor Magenta
Write-Host "......................." -ForegroundColor DarkMagenta

Write-Host "Closing all Chrome and Edge windows..." -ForegroundColor Green

Stop-Process -name chrome 2> $null
Stop-Process -name msedge 2> $null

$ChromePath = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default\" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
$EdgePath = "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\Default\" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)

Write-Host "Cloning Chrome data..." -ForegroundColor Green
#Clone the Login data file and then return the path of the cloned data
Copy-Item "$($ChromePath)\Login Data" -Destination "C:\temp\Chrome\Login Data"
Copy-Item "$($ChromePath)\Bookmarks" -Destination "C:\temp\Chrome\Bookmarks"
Copy-Item "$($ChromePath)\Bookmarks.bak" -Destination "C:\temp\Chrome\Bookmarks.bak"  2> $null
Copy-Item "$($ChromePath)\Bookmarks.mbak" -Destination "C:\temp\Chrome\Bookmarks.mbak"  2> $null

Copy-Item "$($EdgePath)\Login Data" -Destination "C:\temp\Edge\Login Data"
Copy-Item "$($EdgePath)\Bookmarks" -Destination "C:\temp\Edge\Bookmarks"
Copy-Item "$($EdgePath)\Bookmarks.bak" -Destination "C:\temp\Edge\Bookmarks.bak"  2> $null
Copy-Item "$($EdgePath)\Bookmarks.mbak" -Destination "C:\temp\Edge\Bookmarks.mbak" 2> $null

& "C:\temp"
explorer.exe $EdgePath