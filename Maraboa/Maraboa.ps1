<#
    .SYNOPSIS
    Scrape data from HaloPSA API
#>
<#Barclay McClay - 2023 #>

Write-Host @"
,---.    ,---.   ____    .-------.       ____     _______       ,-----.       ____     
|    \  /    | .'  __  . |  _ _   \    .'  __  . \  ____  \   .'  .-,  '.   .'  __  .  
|  ,  \/  ,  |/   '  \  \| ( ' )  |   /   '  \  \| |    \ |  / ,-.|  \ _ \ /   '  \  \ 
|  |\_   /|  ||___|  /  ||(_ o _) /   |___|  /  || |____/ / ;  \  '_ /  | :|___|  /  | 
|  _( )_/ |  |   _.-    || (_,_).' __    _.-    ||   _ _ '. |  _ ,/ \ _/  |   _.-    | 
| (_ o _) |  |.'   _    ||  |\ \  |  |.'   _    ||  ( ' )  \: (  '\_/ \   ;.'   _    | 
|  (_,_)  |  ||  _( )_  ||  | \ \'   /|  _( )_  || (_ O _) | \  "/  \  ) / |  _( )_  | 
|  |      |  |\ (_ o _) /|  |  \    / \ (_ o _) /|  (_,_)  /  '. \_/  ".'  \ (_ o _) / 
'--'      '--' '.(_/_).' ''-'    '-'   '.(_\_).' /_______.'     '-----'     '.(_\_).'  
"@ -ForegroundColor Magenta
Write-Host "=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=" -ForegroundColor DarkMagenta
##
if(-not (Get-Module HaloAPI -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`n(First time set-up)..." -ForegroundColor DarkRed
    Install-Module HaloAPI -Scope CurrentUser
}
##
function formatDate($date) {
    #Switches between mm/dd/yyyy and dd/mm/yyyy
    $arr = $date.Split("/")
    return "$($arr[1])/$($arr[0])/$($arr[2])"
}

$MaraboaDateSelect = "$($PSScriptRoot)\Mara-DateSelect.ps1"

function MaraboaTicketStats {
    param(
        [string]$searchClient='ALL',
        [string]$searchParam='OPENED',
        [string]$dateStart="$(Get-Date -Format 'MM/dd/yyyy')",
        [string]$dateEnd="$(Get-Date -Format '12/31/2099')"
    )
    Do {
    Write-Host @"
+--------------------------------------------+
|               TICKET STATS                 |
+--------------------------------------------+`n
"@ -ForegroundColor Magenta
    Write-Host "Current search: $($searchClient) tickets $($searchParam) from $(formatDate($dateStart)) until $(formatDate($dateEnd))." -ForegroundColor Yellow
    Write-Host @"
`n[1] Change '$($searchClient)' search focus
[2] Change '$($searchParam)' search parameter
[3] Change search start date '$(formatDate($dateStart))'
[4] Change search end date '$(formatDate($dateEnd))'

[<Enter>] Start search with current parameters.
[Q] Go back
"@ -ForeGroundColor Cyan
    $tsOpt1 = Read-Host
    switch($tsOpt1){
        'q' {
            break
        }
        1{
            break
        }
        2 {
            Do {
                Write-Host "Current search: $($searchClient) tickets ________ from $(formatDate($dateStart)) until $(formatDate($dateEnd))." -ForegroundColor Yellow
                Write-Host @"               
[1] OPENED
[2] CLOSED
[3] ASSIGNED
[4] LAST ACTIONED
"@ -ForegroundColor Cyan
                $tsOpt2 = Read-Host
                switch($tsOpt2){
                    1 {
                        $searchParam='OPENED'
                        break
                    }
                    2 {
                        $searchParam='CLOSED'
                        break
                    }
                    3 {
                        $searchParam='ASSIGNED'
                        break
                    }
                    4 {
                        $searchParam='LAST ACTIONED'
                        break
                    }
                    default {
                        Write-Host "Invalid Input" -ForegroundColor DarkGray
                    }
                }
            }Until($tsOpt2)
            break
        }
        3 {
            Write-Host "Current search: $($searchClient) tickets $($searchParam) from ________ until $(formatDate($dateEnd))." -ForegroundColor Yellow
            $dateStart = . $MaraboaDateSelect
            break
        }
        4{
            Write-Host "Current search: $($searchClient) tickets $($searchParam) from $(formatDate($dateStart)) until ________." -ForegroundColor Yellow
            $dateEnd = . $MaraboaDateSelect
        }
        "" {
            switch ($searchParam) {
                'OPENED' { 
                    $dateSearch = 'dateoccurred'
                 }
                 'CLOSED' {
                    $dateSearch = 'dateclosed'
                 }
                 'ASSIGNED' {
                    $dateSearch = 'dateassigned'
                 }
                 'LAST ACTIONED' {
                    $dateSearch = 'lastactiondate'
                 }
            }
            $tickets = Get-HaloTicket -DateSearch $dateSearch -StartDate $dateStart -EndDate $dateEnd | Format-Table
            Write-Host "There were $($tickets.count) $($searchClient) from $(formatDate($dateStart)), until $(formatDate($dateEnd))."
            Write-Host ""
            Write-Host ""
            break
        }
        default {
            Write-Host "Invalid Input - Please enter an option listed above." -ForegroundColor DarkGray
        }
    }

    #
    #$dateEnd = . $MaraboaDateSelect
    #$tickets = Get-HaloTicket -DateSearch "dateoccurred" -StartDate $dateStart -EndDate $dateEnd
    #Write-Host "There were $($tickets.count) tickets opened from $(formatDate($dateStart)) to $(formatDate($dateEnd))"
}Until($tsOpt1 -eq 'q')

}

#TICKET SEARCH
function findTicket {
    #List potential filters > feed into Get-HaloTicket, return ticket IDs, offer to open in browser.
    Write-Host @"
+--------------------------------------------+
|               TICKET SEARCH                |
+--------------------------------------------+`n
"@ -ForegroundColor Magenta
    Write-Host "Available Filters, select to apply:
    `n[1] Client"
    $filterOpt1 = Read-Host
    
    switch ($filterOpt1) {
        '1' { #apply client filter
            Write-Host "Specify a client by number, name or partial name. Enter q to go back."
            $clientList = @(Get-HaloClient | Select-Object name) #capture client names in an array and display        
            $i = 0
            Do{
                Write-Host "$($i+1). $($clientList[$i].name)"
                $i++     
            }Until($i -ge $clientList.count)
            $clientOpt = Read-Host
                switch ($clientOpt) {
                    'q' {
                        break
                    }
                    default {
                        Try {   #test for integer inputs
                            if (($clientList.count -ge $clientOpt) -and ($clientOpt -gt 0)) {
                                $selectedClient = $clientList[$clientOpt - 1]
                                Write-Host "Client Selected: $($selectedClient.Name)"
                            }
                            else {
                            Write-Host ("Enter a number between 1 and $($clientList.count)")
                            }
                        } Catch {   #test for text inputs
                            $selectedClient = search -searchType "client" -searchValue $clientOpt -searchData $clientList
                            Write-Host $selectedClient
                        }
                        
                    
                        break
                    }
                }
            }
    }
    #Open ticket in Edge - URL to call: https://$($hURL)/ticket?id=$($ticketID)&showmenu=false
}

function search ($searchType, $searchValue, $searchData) {
    $result = $searchData.name.ToLower() | ForEach-Object { if($_.contains($searchValue.ToLower())){$_} }
    Try {
        if ($result.count -gt 1) {
            Write-Host "$($result.count) matches found."
            $i=0
            Do {
                Write-Host "$($result[$i].name)"
                $i++
            } Until($i -eq $result.count)
        } else {
            if($searchData.name.ToLower().contains($result.ToLower())){
                return $searchData | Where-Object {$_.name.ToLower() -contains $result.ToLower()}
                }
        } else {
            return "No relevant $($searchType) entry found. Try again."
        }
    } Catch {
        return "No relevant $($searchType) entry found. Try again."
    }
}

################################# CONNECT TO HALO API ##########################################
Try {
    $config = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent
    $config = Get-Content "$($config)\.config.json" | ConvertFrom-Json
    $hURL=$config.HALO_URL
    $hID=$config.HALO_ID
    $hSecret=$config.HALO_SECRET
}Catch{
    Write-Host "Could not find .config.json, or there was an error pulling credentials from it." -ForegroundColor Red
    exit
}
Connect-HaloAPI -URL $hURL -ClientID $hID -ClientSecret $hSecret
################################################################################################
Do {
    Write-Host @"
[T] Ticket Stats
[S] Ticket Search
[?] Display help
[Q] Quit
"@ -ForegroundColor Cyan
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
    't' {
        MaraboaTicketStats
        break
    }
    's' {
        findTicket
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