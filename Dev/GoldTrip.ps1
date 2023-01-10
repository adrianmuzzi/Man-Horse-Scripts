<#
.SYNOPSIS
API Practice
#>

$token=""
$method='GET'
$contentType='application/json'
$body='{"page": "0","size": "20","sort": "name"}'

Invoke-WebRequest -Uri "https://api.pax8.com/v1/companies" -Method $method -ContentType $contentType -Body $body 

#########################################################################################################################################
#
#
#
#                                                           NOTHING BELOW THIS LINE
#########################################################################################################################################