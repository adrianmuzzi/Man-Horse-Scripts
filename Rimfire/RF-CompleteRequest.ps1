<#
    .SYNOPSIS
    We are passed ticket data and are tasked with completing the request.

    .PARAMETER userID
    The ticket number of the request.
#>
param (
    [int]$ticketID
)

$selectedTicket = Get-HaloTicket -TicketID $ticketID

# $RFSelectEdgeProfile = ".\RF-SelectEdgeProfile.ps1"


#############################################################################################
Start-Transcript -Path "C:/Temp/$($ticketID)-Ticket-Log.log"
# Get a bit of info about the ticket:
Write-Host "Processing ticket #$($ticketID)..." -ForegroundColor Green
Write-Host $selectedTicket.summary -ForegroundColor DarkGreen
Write-Host "Client: $($selectedTicket.user.client_name)" -ForegroundColor DarkGray
$ticketUser = Get-HaloUser -UserID $selectedTicket.user.id
$azureDomain = $selectedTicket.user.azure_tenant_domain;        Write-Host "Azure Domain: $azureDomain" -ForegroundColor DarkGray
$AzureTenantID = $ticketUser.azure_tenant_id;                   Write-Host "Azure Tenant: $AzureTenantID" -ForegroundColor DarkGray
$ticketAgent = Get-HaloAgent -AgentID $selectedTicket.agent_id; Write-Host "Agent: $($ticketAgent.name)" -ForegroundColor DarkGray
# We need to see what kind of request it is:
Write-Host "Determining ticket-type..." -ForegroundColor Blue
switch ($selectedTicket.tickettype_id) {
    # Each possible ticket-type is represented in the switch below. If more ticket types are added/these ones are altered in halo- this switch will need updating to refelect it.
    # Tickets called 'Request - *' are service-requests. They will have custom fields where information can be reliably found.
     1 {Write-Host "Sorry- Invalid ticket type (Incident)" -ForegroundColor Red; Stop-Transcript; return; }
     2 {Write-Host "Sorry- Invalid ticket type (Change Request)" -ForegroundColor Red; Stop-Transcript; return; }
     3 {Write-Host "Sorry- Invalid ticket type (Service Request - Generic)" -ForegroundColor Red; Stop-Transcript; return; }
     4 {Write-Host "Sorry- Invalid ticket type (Problem)" -ForegroundColor Red; Stop-Transcript; return; }
     5 {Write-Host "Sorry- Invalid ticket type (Project)" -ForegroundColor Red; Stop-Transcript; return; }

     7 {
        Write-Host "Request - New/Additional Hardware" -ForegroundColor DarkGreen
        
     }
    
     14 {
        Write-Host "Request - Add/Remove Printer" -ForegroundColor DarkGreen
        
     }
    16 {
        Write-Host "Request - Departing User" -ForegroundColor Red
        
     }
    17 {
        Write-Host "Request - New User" -ForegroundColor DarkGreen

        function RFGeneratePassword {
            $n = Get-Random -Maximum 1000
            $WordListUri = "https://raw.githubusercontent.com/chelnak/MnemonicEncodingWordList/master/mnemonics.json"
            $WordListObject = Invoke-RestMethod -Method Get -Uri $WordListUri
            $word = Get-Random -InputObject $WordListObject.words -Count 1
            $pass = $word.substring(0,1).toupper()+$word.substring(1).tolower()
            $pass += "$($n)"
            $pass += "$"
            return $pass
        }

        $i = 0
        Do {
            Write-Host "$($selectedTicket.customFields.label[$i]): $($selectedTicket.customFields.value[$i])" -ForegroundColor Blue
            $i++
        }Until($i -ge $selectedTicket.customFields.count)
        $val = $selectedTicket.customFields.value
        Write-Host "Creating new user with Graph..." -ForegroundColor DarkBlue
        $pass = @{
            forceChangePasswordNextSignIn=$true
            forceChangePasswordNextSignInWithMfa=$false
            password= RFGeneratePassword
        }
        $usrName = "$($val[0]) $($val[1])"
        # They might put 'john.smith' or they might put 'john.smith@contoso.com'
        # So sanitise incase of the latter
        if($val[2] -match "@"){
            $mail = $val[2]
            $mailNick = $val[2].Substring(0, $val[2].IndexOf('@'))
        }else{
            $mail = "$($val[2])@$azureDomain"
            $mailNick = $val[2]
        }

        Connect-MgGraph -TenantId $AzureTenantID
        $newUser = New-MgUser -GivenName $val[0] -Surname $val[1] -DisplayName $usrName -Mail $mail -UserPrincipalName $mail -MobilePhone $val[3] -JobTitle $val[4] -PasswordProfile $pass -AccountEnabled:$true -MailNickname $mailNick
        $newUser
        # Log into AAD tenant
        #$EdgeProfileFolder = . RFSelectEdgeProfile
        #Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"-ArgumentList "--profile-directory=`"$($EdgeProfileFolder)`" about:blank)"
     }
    18 {
        Write-Host "Request - Drive/Folder Access" -ForegroundColor DarkGreen

     }
    19 {
        Write-Host "Request - Add/Remove Software" -ForegroundColor DarkGreen

     }
    20 { Write-Host "Sorry- Invalid ticket type (Task)" -ForegroundColor Red; Stop-Transcript; return; }
    21 {
        Write-Host "Email Inbox Access Request" -ForegroundColor DarkGreen

     }
    22 {
        Write-Host "Request - Modify User Details " -ForegroundColor DarkGreen

     }
    23 {
        Write-Host "Request - Phone Diversion " -ForegroundColor DarkGreen

     }
    24 {
        Write-Host "Request - Out of Office / Forward Emails" -ForegroundColor DarkGreen

     }
    25 {
        Write-Host "Request - Configure user on workstation " -ForegroundColor DarkGreen

     }
    29 {Write-Host "Sorry- Invalid ticket type (Non self-service request)" -ForegroundColor Red; Stop-Transcript; return; }
    30 {Write-Host "Invalid ticket type: Request - Departing User (Test)" -ForegroundColor Red; Stop-Transcript; return; }
    31 {Write-Host "Sorry- Invalid ticket type (Alert/Informational)" -ForegroundColor Red; Stop-Transcript; return; }
    32 {Write-Host "Sorry- Invalid ticket type (Opportunity)" -ForegroundColor Red; Stop-Transcript; return; }
    34 {Write-Host "Sorry- Invalid ticket type (Web Dev Request)" -ForegroundColor Red; Stop-Transcript; return; }
    35 {Write-Host "Sorry- Invalid ticket type (Lead)" -ForegroundColor Red; Stop-Transcript; return; }
    36 {Write-Host "Sorry- Invalid ticket type (Internal Note)" -ForegroundColor Red; Stop-Transcript; return; }
    Default {
        Write-Host "Error - Unrecognised ticket type" -ForegroundColor Red
        Stop-Transcript
        return
    }
}

Stop-Transcript

