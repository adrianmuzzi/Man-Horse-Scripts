# Man-Horse-Scripts
A collection of Powershell scripts I have developed to shave milliseconds off of the time it takes me to do something at work. They are all named for Melbourne Cup winners.

# Cross Counter
Employee email signatures use information scraped from Azure Active Directory. This keeps information consistent accross all company media- but the tradeoff is that everytime someone changes their mobile number, address, name, etc. an IT sys admin has to be called to log into AAD and make the appropriate changes.
AAD is a beast, with many different menus, submenus, settings, tabs etc. *Cross Counter* simplifies the experience:
- Login to the desired tenant in the popup window.
- Find the user in the alphabetical list that Cross Counter populates.
- Skip straight to editing any of the 11 common email signature fields in AAD.
- Once done, you can select another user, or log-out and exit.
