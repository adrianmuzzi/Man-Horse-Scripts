<#
IT Support Bot
This script is designed to provide IT support agents with an automated chatbot that can assist with processing support tickets. It makes use of the HaloAPI PowerShell module to connect to the ticketing system and OpenAI's GPT-3.5 API for the chatbot.

Usage
Before running the script, ensure that you have installed the HaloAPI PowerShell module. If it is not installed, the script will attempt to install it automatically. You will also need to create a .config.json file in the script directory containing the following fields:

json
Copy code
{
    "HALO_URL": "https://your.halo.url",
    "HALO_ID": "your_client_id",
    "HALO_SECRET": "your_client_secret",
    "OPENAI_KEY": "your_openai_api_key"
}
#>
 $title1 = @"
 (                                    
 )\ )            (                    
(()/( (      )   )\ )  (   (      (   
 /(_)))\    (   (()/(  )\  )(    ))\  
(_)) ((_)   )\  '/(_))((_)(()\  /((_)
"@
$title2 = @"
| _ \ (_) _((_))(_) _| (_) ((_)(_))   
|   / | || '  \  |  _| | || '_|/ -_)  
|_|_\ |_||_|_|_| |_|   |_||_|  \___|
"@
Write-Host $title1 -ForegroundColor Yellow
Write-Host $title2 -ForegroundColor Red
Write-Host "=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-==-=`n" -ForegroundColor DarkRed

##
if(-not (Get-Module HaloAPI -ListAvailable)){
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Write-Host "`nLooks like you don't have the required module.`n(First time set-up)..." -ForegroundColor DarkRed
    Install-Module HaloAPI -Scope CurrentUser
}
##
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
##

$aiURL = "https://api.openai.com/v1/chat/completions"
$aiHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $($config.OPENAI_KEY)"
}

$ACSetup = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent
$ACSetup = $ACSetup+"\Acrasia\ACRASIA-Setup.ps1"

#######################################################################################################################
# Start Functions 

$RFCompleteRequest = "$($PSScriptRoot)\RF-CompleteRequest.ps1"

function RFResetConversation {
return @(
    @{
        role = "system"
        content = "Tech Support Bot"
    },
    @{
        role = "user"
        content = "You're a customer service agent for an IT provider in Australia, and your role is to process emails as new support tickets."#When asked to categorise a ticket, you will do so out of the following list: $($ticketCategories.value)"
    }
)
}

function RFListTickets($tickets) {
    $i = 0
    Do{
        #List Tickets
        $ticketAgent = Get-HaloAgent -AgentID $tickets[$i].agent_id
        $ticketDetails = "$($tickets[$i].summary) | $($tickets[$i].user_name) | $($tickets[$i].client_name)"
        switch ($tickets[$i].status_id) {
            1 { Write-Host "$($tickets[$i].id) **NEW** $($ticketDetails)**NEW**" -ForegroundColor Yellow } #NEW
            2 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (In Progress...) $($ticketDetails)" -ForegroundColor DarkGreen } #In Progress
            3 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (ACTION REQUIRED) $($ticketDetails)" -ForegroundColor DarkYellow } #Action Required
            4 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (Awaiting User) $($ticketDetails)" -ForegroundColor Blue } #Awaiting User
            5 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (With Supplier) $($ticketDetails)" -ForegroundColor DarkGray } #With Supplier
            17 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (Awaiting Approval) $($ticketDetails)" -ForegroundColor Cyan } #Awaiting Approval
            20 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (Scheduled) $($ticketDetails)" -ForegroundColor DarkRed } #Scheduled
            21 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (Responded) $($ticketDetails)" -ForegroundColor Magenta  } #Responded
            22 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (Needs Action) $($ticketDetails)" -ForegroundColor DarkYellow  } #Needs Action
            26 { Write-Host "$($tickets[$i].id) $($ticketAgent.Name) (Escalated) $($ticketDetails)" -ForegroundColor Gray  } #Escalated
            Default {Write-Host "$($tickets[$i].id) $($ticketDetails)"}
        }
        
        $i++
    }Until($i -ge $tickets.count - 1)
}

function RFViewTicket($selectedTicket){
    switch($selectedTicket.status_id) {
        1 { Write-Host "$($selectedTicket.id) **NEW**" -ForegroundColor Yellow } #NEW
        2 { Write-Host "$($selectedTicket.id) (In Progress...)" -ForegroundColor DarkGreen } #In Progress
        3 { Write-Host "$($selectedTicket.id) (ACTION REQUIRED)" -ForegroundColor DarkYellow } #Action Required
        4 { Write-Host "$($selectedTicket.id) (Awaiting User)" -ForegroundColor Blue } #Awaiting User
        5 { Write-Host "$($selectedTicket.id) (With Supplier)" -ForegroundColor DarkGray } #With Supplier
        17 { Write-Host "$($selectedTicket.id) (Awaiting Approval)" -ForegroundColor Cyan } #Awaiting Approval
        20 { Write-Host "$($selectedTicket.id) (Scheduled)" -ForegroundColor DarkRed } #Scheduled
        21 { Write-Host "$($selectedTicket.id) (Responded)" -ForegroundColor Magenta  } #Responded
        22 { Write-Host "$($selectedTicket.id) (Needs Action)" -ForegroundColor DarkYellow  } #Needs Action
        26 { Write-Host "$($selectedTicket.id) (Escalated)" -ForegroundColor Gray  } #Escalated
        Default { Write-Host "$($selectedTicket.id)" }
    }
    Write-Host "$($selectedTicket.user.name)" -ForegroundColor Cyan
    Write-Host "$($selectedTicket.user.client_name)" -ForegroundColor Cyan
    Write-Host "$($selectedTicket.user.emailaddress)" -ForegroundColor Cyan
    #Display ALL a client's possible ph. Numbers
    $phoneNumbers = @(
        $selectedTicket.user.phonenumber_preferred, 
        $selectedTicket.user.sitephonenumber, 
        $selectedTicket.user.phonenumber,
        $selectedTicket.user.mobilenumber2
        )
    $phoneNumbers = $phoneNumbers | Select-Object -Unique
    $i=0
    Do{
        if($phoneNumbers[$i] -ne ""){
            Write-Host $phoneNumbers[$i] -ForegroundColor Cyan
        }
        $i++
    }Until($i -ge $phonenumbers.count)
    ##
    $ticketAgent = Get-HaloAgent -AgentID $selectedTicket.agent_id
    Write-Host "Assigned to: $($ticketAgent.name)" -ForegroundColor DarkCyan
    Write-Host "Category: $($selectedTicket.category_1)" -ForegroundColor DarkCyan
    ######
    Do{
        Write-Host "`n[1] - Complete Request`n[2] - Ticket Admin (GPT)`n[Q] - Go Back" -ForegroundColor Yellow
        $ticketPrompt = Read-Host
        switch($ticketPrompt){
            1{
                . $RFCompleteRequest -TicketID $selectedTicket.id
            }
            2{
                RFTicketAdminGPT
            }
            'q' {
                Break
            }
            Default {
                Write-Host "Please input an option listed in the menu."   -ForegroundColor Red
            }
        }
    }Until($ticketPrompt -eq 'q')
}

function RFTicketAdminGPT {
 #GPT function
 $conversation = RFResetConversation
 $conversation += @{
     role = "user"
     content = "The following is the body text of an email titled '$($selectedTicket.summary)'. I am going to ask you to perform a few tasks with this email. First, I want you to:`n- Provide a succinct 'subject' headline for the email,`n- Summarise the message in three to four sentences. "
 }
 $conversation += @{
     role = "user"
     content = "$($selectedTicket.details)"
 }
 RFChatGPT
}

function RFChatGPT{
    $aiBody = @{
        model = "gpt-3.5-turbo"
        messages = $conversation
        temperature = 0.4
    } | ConvertTo-Json
    <#
    $response = Invoke-RestMethod -Method Post -Uri $aiURL -Headers $aiHeaders -Body $aiBody
    $response = $response.choices.message.content
    $conversation += @{
        role = "assistant"
        content = "$($response.choices.message.content)"
    }
    #> $response = "The chatGPT functionality has been coded out temporarily"
    Write-Host $response -ForegroundColor Cyan
}
# End of functions
####################################################################################################################
#Start do... until loops

$conversation = RFResetConversation
$helpTxt = @"
.___________________________________________.
 [1] - List today's open Customer Service tickets
 [2] - New/Unresponded Tickets
 [3] - Tickets by Client
 [4] - Tickets by Agent
 [5] - Ticket by ID
 [6] - Service Requests
 [CHAT] - Start new conversation with GPT
 [RESET] - Manual reset of GPT
 [HELP] - Show this text      
 [Q] -  Quit               
.___________________________________________.
"@

Do{
    $conversation = RFResetConversation
    Write-Host $helpTxt -ForegroundColor Yellow
    $prompt = Read-Host
    Switch($prompt){

        1 { # List all of the open tickets in the customer service queue today.
            Write-Host "`n.___________________________________________.`n" -ForegroundColor DarkYellow
            Write-Host "Open Customer Service tickets as at $(Get-Date -UFormat "%A %d/%m/%Y %R")`n" -ForegroundColor DarkYellow
            $tickets =   Get-HaloTicket -Team 1 -OpenOnly | Sort-Object -Property "status_id"
            RFListTickets -tickets $tickets
            Do {
                Write-Host "`nEnter a ticket ID, or 'q' to go back." -ForegroundColor DarkYellow
                $IDprompt = Read-Host
                if($IDprompt -ne ""){
                    Try {
                        $selectedTicket = Get-HaloTicket -TicketID $IDprompt
                        if($selectedTicket){
                            #Do the thing
                            RFViewTicket -selectedTicket $selectedTicket
                        }else{ #wrong number
                                Write-Host "Please input an option listed in the menu."   -ForegroundColor Red
                        }
                    } Catch { #likely a string input
                        if($IDprompt -ne 'q'){
                            Write-Host "$($_)" -ForegroundColor DarkRed
                            Write-Host "Input the ID number listed beside the ticket you wish to select,`nor 'q' to go back." -ForegroundColor Red
                        }
                    }
                }else{
                        Write-Host "Please input a ticket ID #"   -ForegroundColor Red
                }
            }Until($IDprompt -eq 'q')
            Break
        }
    
        2 {  #new (unresponded) tickets
            $tickets = Get-HaloTicket -Team 1 -OpenOnly -status 1
            Try{
                $i = 0
                Do{
                    Write-Host "$($tickets[$i].id) - $($tickets[$i].summary) - $($tickets[$i].user_name), $($tickets[$i].client_name)" -ForegroundColor Yellow
                    $i++
                }Until($i -ge $tickets.count - 1)
            }Catch{
                Write-Host "No new tickets found" -ForegroundColor DarkRed
            }
        }
        "HELP" {
            Write-Host $helpTxt -ForegroundColor Yellow
            Break
        }
        "q" {
            Break
        }
        "CHAT"{
            Write-Host "Describe the personality of your new bot..." -ForegroundColor Yellow
            $promptPersonality = Read-Host
            $conversation = @(
                @{
                    role = "system"
                    content = $($promptPersonality)
                },
                @{
                    role = "user"
                    content = "You are a bot programmed to be $($promptPersonality) for this conversation. Let's begin, introduce yourself in one sentence."
                }
            )
            Write-Host "New conversation with a '$($promptPersonality)' bot;`n'q' to exit." -ForegroundColor Yellow
            Do{
                $chatPrompt = Read-Host
                if($chatPrompt -ne "q"){
                    $conversation += @{
                        role = "user"
                        content = "$($chatPrompt)"
                    }
                    RFChatGPT
                }
            }Until($chatPrompt -eq "q")
            Break
        }

        3 { #list clients
            $haloClients = Get-HaloClient -Order "name"
            $i = 0
            Do{
                Write-Host "[$($i+1).] $($haloClients[$i].name)" -ForegroundColor Yellow
                $i++
            }Until($i -ge $haloClients.count)

            Write-Host "`n$($haloClients.count) Active Clients in HaloPSA...`n" -ForegroundColor DarkGray
            Write-Host "Input the number listed next to the client you wish to select,`nor 'q' to go back." -ForegroundColor DarkYellow
            Do {
                $clientPrompt = Read-Host
                    Try {
                        if(($haloClients.count -ge $clientPrompt)-and($clientPrompt -gt 0)){
                            Write-Host $haloClients[$($clientPrompt - 1)].name -ForegroundColor Yellow
                        }else{
                            Write-Host "Please input an option listed in the menu."   -ForegroundColor Red
                        }
                    } Catch {
                        if($clientPrompt -ne 'q'){
                            Write-Host "Input the number listed next to the client you wish to select,`nor 'q' to go back." -ForegroundColor Red
                        }
                    }   
            }Until($clientPrompt -eq 'q')
            Break
        }

        4{ #tickets by agent
            $agents = Get-HaloAgent | Sort-Object -Property "name"
            $i = 0
            Do{
                $tickets = Get-HaloTicket -AgentID $agents[$i].id -OpenOnly
                Write-Host "[$($i+1)] $($agents[$i].name) ($($tickets.Count))" -ForegroundColor Yellow
                $i++
            }Until($i -ge $agents.count)
            #Pick an agent
            Do{
                Write-Host "`nInput the number listed next to the agent you wish to select. (or 'q' to go back)" -ForegroundColor DarkYellow
                $agentPrompt = Read-Host
                switch($agentPrompt){ #this is a switch instead of 'if', to make adding possible additional options easy later
                    'q'{
                        Break
                    }
                    Default{
                        try {
                            $agentPrompt = $agentPrompt-1
                            if($agents[$agentPrompt]){
                                Write-Host "`n$($agents[$agentPrompt].name)" -ForegroundColor Green
                                $tickets = Get-HaloTicket -AgentID $agents[$agentPrompt].id -OpenOnly
                                RFListTickets -tickets $tickets
                            }else{
                                Write-Host "Please input an option listed in the menu."   -ForegroundColor Red
                            }
                        }
                        catch {
                            Write-Host "Invalid Input. Please enter an option listed in the menu."   -ForegroundColor Red
                        }
                    }
                }
            }Until($agentPrompt -eq 'q')
        }
        
        5 { #enter id direct
            $tickets =   Get-HaloTicket -Team 1 -OpenOnly
            Do {
                Write-Host "`nEnter a ticket ID, or 'q' to go back." -ForegroundColor DarkYellow
                $IDprompt = Read-Host
                if($IDprompt -ne ""){
                    Try {
                        $selectedTicket = Get-HaloTicket -TicketID $IDprompt
                        if($selectedTicket){
                            #Do the thing
                            RFViewTicket -selectedTicket $selectedTicket
                        }else{ #wrong number
                                Write-Host "Please input a ticket ID."   -ForegroundColor Red
                        }
                    } Catch { #likely a string input
                        if($IDprompt -ne 'q'){
                            Write-Host "$($_)" -ForegroundColor DarkRed
                            Write-Host "Input the ID number of the ticket you wish to select,`nor 'q' to go back." -ForegroundColor Red
                        }
                    }
                }
            }Until ($IDprompt  -eq "q")
        }

        6 { #Service Requests
            $tickets = Get-HaloTicket -OpenOnly
        }

        "RESET"{
            $conversation = RFResetConversation
            Write-Host "GPT AI prompts reset" -ForegroundColor Green
            Break
        }

        Default{
            Write-Host "Invalid Input. Pick from the menu:" -ForegroundColor Red
            Write-Host $helpTxt -ForegroundColor Yellow
        }
    }
}Until($prompt -eq "q")

#
exit
##################################################################################################################
#                                               END END END