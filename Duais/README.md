# Duais
__Ver 0.1__

*Duais* *(Do-ay-iss)* takes a file at a give filepath, renames it, then replaces it with a file.
You must specify the files by manually editing the script before use.


## Setup

Before starting, duplicate the Duais folder to a new location. Open the new version, and edit the main `Duais.ps1` script.

You will find these three variables at the top of the script.

```
$NewFile =               #Full path of the new file
$TargetLocation =        #Path of the target file's parent folder
$TargetName =            #Filename of target file
```

Say you wanted to replace a user's `Normal.dotm` file, found at `%appdata%\Microsoft\Templates`:

1. Duplicate the `Duais` folder to a new location (for eg. C:\\Temp\\)
2. Copy the new `Normal.dotm` file to the new Duais folder.
3. Open `Duais.ps1` in a text editor or IDE. Change those top variables to:
    - `$NewFile = "C:\Temp\Duais\Normal.dotm"` 
    - `$TargetLocation = "$($env:appdata)\Microsoft\Templates"`
    - `$TargetName =  "Normal.dotm"`
4. Run Duais:

- Duais will rename `Normal.dotm` found at `$($env:appdata)\Microsoft\Templates\` to `Normal.dotm.bak`
- Duais will then copy the file at `C:\Temp\Duais\Normal.dotm` to `$($env:appdata)\Microsoft\Templates\`
- Duais will then validate the new file's hash to make sure the copy was a success.