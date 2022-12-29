# Duais

*Duais* *(Do-ay-iss)* was created with Intune packaging in mind.
The script takes a file at a given filepath, renames it, then replaces it with another specified file.
There is then a second script that validates the operation completed successfully.

## Setup

Before starting, duplicate the Duais folder to a new location.
Open the new folder, and edit the main `Duais.ps1` script.

You will find these three variables at the top of the script.

```
$NewFile =               #Full path of the new file
$TargetLocation =        #Path of the target file's parent folder
$TargetName =            #Filename of target file
```

Open `DuaisDetection.ps1` and you will find two variables:

```
$FileLocation =     #Full Path of the file you are changing
$FileHash =         #Hash of the file you want to end up with
```

These five variables will need values assigned to them.

## Worked example:

Say you wanted to replace a user's `Normal.dotm` file, found at `%appdata%\Microsoft\Templates`:

1. Duplicate the `Duais` folder to a new location (for eg. C:\\Temp\\)
2. Copy the new `Normal.dotm` file to the new Duais folder (in this case C:\\Temp\\Duais).
3. Open `Duais.ps1` in an editor. Change those top variables to:
    - `$NewFile = "C:\Temp\Duais\Normal.dotm"` 
    - `$TargetLocation = "$($env:appdata)\Microsoft\Templates"`
    - `$TargetName =  "Normal.dotm"`
4. Open `DuaisDetection.ps1` in an editor and change:
    - `$FileLocation =  "$($env:appdata)\Microsoft\Templates\Normal.dotm"`
5. Open __PowerShell__ and input:
    
    `Get-FileHash "C:\Temp\Duais\Normal.dotm"`

PowerShell will return `Algorithm`, `Hash` and `Path` values. Copy the 'Hash' value (a long string of seemingly random characters) into:
    - `$FileHash =         #Hash of the file you want to end up with`

6. Save it all. The script(s) were made to be packaged into Intune/Microsoft Endpoint Manager with DuaisDetection as a 'custom detection' script. Install/Uninstall command is:

`powershell.exe -executionpolicy bypass -file .\Duais.ps1`

Running the script:
- Duais will rename `Normal.dotm` found at `$($env:appdata)\Microsoft\Templates\` to `Normal.dotm.bak`
- Duais will then copy the file at `C:\Temp\Duais\Normal.dotm` to `$($env:appdata)\Microsoft\Templates\`
- DuaisDetection will validate the new file's hash to make sure the copy was a success.

__Log files are stored in `C:\MDM\`__