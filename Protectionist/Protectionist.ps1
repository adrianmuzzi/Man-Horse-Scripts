<#Barclay McClay - 2022 #>
# NOTE: ALWAYS USE THESE PASSWORDS WITH MFA/C.A.
<#
  _____   ______  _____  _______ _______ _______ _______ _____  _____  __   _ _____ _______ _______
 |_____] |_____/ |     |    |    |______ |          |      |   |     | | \  |   |   |______    |   
 |       |    \_ |_____|    |    |______ |_____     |    __|__ |_____| |  \_| __|__ ______|    |   
                                                                                                   
#>
function Get-MnemonicWord {
try {
        $WordListUri = "https://raw.githubusercontent.com/chelnak/MnemonicEncodingWordList/master/mnemonics.json"
        $WordListObject = Invoke-RestMethod -Method Get -Uri $WordListUri
        $w = Get-Random -InputObject $WordListObject.words -Count 1
        return $w
    }
    catch [Exception]{
        throw "Could not retrieve Mnemonic Word List: $($Exception.Message)"
    }
}

$n = Get-Random -Maximum 1000
$word = Get-MnemonicWord
$pass = ($word).substring(0,1).toupper()+($word).substring(1).tolower()
$pass += "-"
$pass += "$($n)"
Write-Host $pass -ForegroundColor Cyan
Set-Clipboard -Value $pass
Write-Host "Copied to clipboard..." -ForegroundColor DarkCyan
return

#########################################################################################################################################
#
#
#
#                                                           NOTHING BELOW THIS LINE
##########################################################################################################################################