<#
    .SYNOPSIS
    Converts input M365 product SKU into the product name.
    Note this does not cover a majority of M365 Licenses- only commonly used ones.
#>
param(
    [string]$SKU
)
switch($SKU) {
    "3b555118-da6a-4418-894f-7df1e2096870"	{
        return "Microsoft 365 Business Basic (O365_BUSINESS_ESSENTIALS)"
    }
    "dab7782a-93b1-4074-8bb1-0e61318bea0b"{
        return "Microsoft 365 Business Basic (SMB_BUSINESS_ESSENTIALS)"
    }
    "f245ecc8-75af-4f8e-b61f-27d8114de5f3"{
        return "Microsoft 365 Business Standard (O365_BUSINESS_PREMIUM)"
    }
    "ac5cef5d-921b-4f97-9ef3-c99076e5470f"{
        return "Microsoft 365 Business Standard - Prepaid Legacy (SMB_BUSINESS_PREMIUM)"
    }
    "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"{
        return "Microsoft 365 Business Premium (SPB)"
    }
    "05e9a617-0261-4cee-bb44-138d3ef5d965"{
        return "Microsoft 365 E3 (SPE_E3)"
    }
    "078d2b04-f1bd-4111-bbd4-b4b1b354cef4" {
        return "Azure Active Directory Premium P1 (AAD_PREMIUM)"
    }
    "84a661c4-e949-4bd2-a560-ed7766fcaf2b" {
        return "Azure Active Directory Premium P2 (AAD_PREMIUM_P2)"
    }
    "4b9405b0-7788-4568-add1-99614e613b69" {
        return "Exchange Online (Plan 1) (EXCHANGESTANDARD)"
    }
    "19ec0d23-8335-4cbd-94ac-6050e30712fa" {
        return "Exchange Online (PLAN 2) (EXCHANGEENTERPRISE)"
    }
    "3dd6cf57-d688-4eed-ba52-9e40b5468c3e" {
        return "Microsoft Defender for Office 365 (Plan 2) (THREAT_INTELLIGENCE)"
    }
    "cdd28e44-67e3-425e-be4c-737fab2899d3" {
        return "Microsoft 365 Apps for Business (O365_BUSINESS)"
    }
    "b214fe43-f5a3-4703-beeb-fa97188220fc" {
        return "Microsoft 365 Apps for Business	(SMB_BUSINESS)"
    }
    "c2273bd0-dff7-4215-9ef5-2c7bcfb06425" {
        return "Microsoft 365 Apps for enterprise (OFFICESUBSCRIPTION)"
    }
    "6470687e-a428-4b7a-bef2-8a291ad947c9" {
        return "SharePoint Online (Plan 1) (SHAREPOINTSTANDARD)"
    }
    "a9732ec9-17d9-494c-a51c-d6b45b384dcb" {
        return "SharePoint Online (Plan 2) (SHAREPOINTENTERPRISE)"
    }
    "1fc08a02-8b3d-43b9-831e-f76859e04e1a" {
        return "Microsoft 365 Apps for enterprise (OFFICESUBSCRIPTION)"
    }
    "f30db892-07e9-47e9-837c-80727f46fd3d" {
        return "Microsoft Flow Free	(FLOW_FREE)"
    }
    "90d8b3f8-712e-4f7b-aa1e-62e7ae6cbe96" {
        return "Business Apps (free) (SMB_APPS)"
    }
    default{
        return $SKU
    }
}