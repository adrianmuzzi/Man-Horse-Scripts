# Acrasia
__Ver 0.2__

*Acrasia* *(Uh-cray-shuh)* is for managing M365 tenants spread across multiple Edge profiles.

Beyond just quick-launching Edge into a specific profile, Acrasia will increasingly be used to access the other scripts in this repository as more are developed.


## Setup

On launch, Acrasia searches for a file called "`%localappdata%\Local\Microsoft\Edge\User Data\_AcrasiaData.txt`"
If no such file is found, Acrasia will create one for you after running through setup.

'Setup' is a necessary (if admittedly tedious) process wherein each of your Edge profiles are opened one-by-one. You check what profile it is, and input your desired nickname for it into Acrasia. The second profile opens upon inputting a nickname for the first, and so on. It will continue through this process until your've nicknamed *all* of your Edge profiles, then it stores the collected data as a hash table in `_Acrasia.txt` (see path above).

The reason for this is that Chromium (Edge) stores and organises each profile under an unfortunatley generic name; '*Profile 1*'.... '*Profile 2*'... etc.

(See for yourself here: `\%localappdata%\Local\Microsoft\Edge\User Data`)

This makes launching a specific profile through PowerShell or Command Prompt difficult- especially if you have a large number of Edge profiles set up on your device (do *you* know off the top of your head which tenant is '*Profile 14*'? ...You shouldn't). You *can* nickname the profile *within* Edge- but the profile directory is not renamed, and the nickname data is not stored anywhere reliably accessible outside of the application. Thus, we need to manually create the data ourselves with `_Acrasia.txt`.

## Main Menu

The `MAIN MENU`  is only acessible if you have an `_AcrasiaData.txt` file in Edge's User Data folder *(see 'Steup' above)*.

-  ### Enter the number listed next to a profile above
Takes you to the `Acrasia Shortcuts` *(see below)* section for the chosen profile.

- ### setup
Runs Acrasia setup again

- ### q
'q' in the main menu will exit PowerShell.

## Acrasia Shortcuts

When you select a profile, you are taken to a menu like so:

```
[1.] AAD
[2.] M365 Admin Portal
[3.] Exchange Admin Center
[4.] MEM / Intune
[5.] Office 365 Portal
[6.] MS Portals
[B.] Bookmarks
[C.] CrossCounter
[Q.] Go Back
```
- ### Numbered Shortcuts
Inputting a number from the list above will open an Edge browser in the selected Profile, directly onto the chosen page.

- ### B (Bookmarks)
Input 'b' and be taken to a similar list of that profile's bookmarks. You can easily add your own shortcuts to Acrasia by adding the page to your browser profile's bookmarks bar (changes are updated after all browser windows are closed and Acrasia is restarted).

- ### C ([CrossCounter](/CrossCounter/))
This option launches a [CrossCounter](/CrossCounter/) session directly into the profile requested (It will initialise the browser profile by opening an MS Portals tab first).

__!! It is possible to catch the script in a trap if you close the Authentication window without clicking 'Cancel' or trying to sign-in !!__

Sign-in to your general Administrator account and authroise the MsGraph Powershell API call (if prompted). Check the [CrossCounter](/CrossCounter/) docs for more information. Here are the two errors *Acrasia* might throw:

    CrossCounter is not present at the expected directory: <dir>

You must launch Acrasia from a file structure that is the same as this repository's; 

`\<parent folder>\Acrasia\Acrasia.ps1`

With CrossCounter in the same parent folder:

`\<parent folder>\CrossCounter\CrossCounter.ps1`

    CrossCounter Failed...
    <dir>
Note that `CrossCounter Failed` is a different error, and is thrown if the CrossCounter script was *found*; but has failed to launch, your sign-in failed, or CrossCounter has for whatever reason closed ungracefully.