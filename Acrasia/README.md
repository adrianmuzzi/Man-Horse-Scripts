# Acrasia
__Ver 0.1__

*Acrasia* is for managing M365 tenants spread across multiple Edge profiles.

We create a different Edge profile for each tenant we manage to make password managment/SSO more intuitive. Under the hood, Edge stores and organises each profile under an unfortunatley generic name; '*Profile 1*'.... '*Profile 2*'... etc.

(See for yourself here:
`%localappdata%\Local\Microsoft\Edge\User Data`)

This makes launching a specific profile through PowerShell or Command Prompt difficult- especially if you have a large number of Edge profiles set up on your device (do *you* know off the top of your head which tenant is '*Profile 14*'? ...You shouldn't).

Acrasia guides you through 'nicknaming' each of your Edge profiles. You can call them whatever you like for quick-reference, and then you can launch specific profiles directly into to useful URLs straight from the CLI.

## Setup

On launch, Acrasia searches for a file called `%localappdata%\Local\Microsoft\Edge\User Data\_AcrasiaData.txt`. If no such file is found, Acrasia will prompt you to run through setup.

'Setup' opens each of your Edge profiles one-by-one. You check what profile it is, and input your desired nickname for it into Acrasia. The second profile opens upon inputting a nickname for the first, and so on. It will continue through this process until your've nicknamed *all* of your Edge profiles, then it stores the collected data as a hash table in `_Acrasia.txt` (which Acrasia will create at the end of setup at the directory above).

## Main Menu

The `MAIN MENU`  is only acessible if you have an `_AcrasiaData.txt` file in Edge's User Data folder *(see 'Steup' above)*.

-  ### Enter the number listed next to a profile above
See *'Profile Menu*'

- ### list
Re-lists the profiles loaded by Acrasia.

- ### setup
Runs Acrasia setup again

- ### q
'q' in the main menu will exit PowerShell.

## Profile Menu