# Cross Counter

*Cross Counter* is for making fast changes to users in a Microsoft 365 tenant. It utilises the MgGraph powershell module. If you do not have this module, it will prompt you for install.

A web browser will then be launched with a Microsoft login prompt. 
## 'Main Menu' commands

The `MAIN MENU` is the highest level menu in Cross Counter. Upon first singing into the tenant with Cross Counter, you are prompted with a fresh user list and this main menu.

-  ### Enter the number listed next to the user you wish to edit
 Leads to the *Edit User* menu for the user selected from the user list.

- ### all
Leads to the *Edit All Users* menu.

- ### groups
Leads to the *Groups Menu*.

- ### users
This refreshes and re-displays the user list. Note that if changes are made to a user's display name- this may lead to changes in the list ordering (as it is organised alphabetically). Whenever you select a user from the user list,  the 'number' you input to do so is always relevant to the most recent time the user list has been refreshed and displayed.

- ### q
'q' In the main menu will sign out of MgGraph and exit powershell.

## 'Edit User' menu
This menu allows for quick changes to a chosen user in the tenant.
- [1] Display Name: *
- [2] First Name: *
- [3] Last Name: *
- [4] Job Title: *
- [5] Mobile Phone *
- [6] Business Phone *
- [7] Email Address *
- [8] Department
- [9] Street address
- [10] City
- [11] Postal Code
- [12] Country
- [13] Company Name
- [14] Reset Password
- [15] TAP Account

**shows preview*

These options are fairly self explanatory. There is some extra functionality for:
- **Display Name**
  - Editing the Display name will prompt you to change the 'First Name' and 'Last Name' options to match.
- **Email**
  - Changing a user's email presents you with a list of preset options that utilise the 'First Name' and 'Last Name' profile items of the user. It also allows for custom input. ***Note:** This does not change the user's principal name*.
- **Reset Password**
  - This option enables you choose a new password from a list of presets, *or* input a custom password. Users will be prompted to change this password on next sign-in.
- **TAP Account**
  - This will create a new one-time-use **T**emporary **A**ccess **P**assword; valid for the user for the next 60 minutes. It also copies both the user's email and the TAP to the clipboard, and opens a new Edge private window to portal.office.com for convenient sign-in to the user's account.
  ## 'Edit All' menu
The 'Edit All' commands apply  to all the users in the tenant.
- [1] Company Name
- [2] Department
- [3] Street address
- [4] City
- [5] Postal Code
- [6] Country

After a change is input, the script cycles through each user in the tenant and applies the changes one-by-one.

## 'Groups' Menu
The `GROUPS MENU` is presented alongside a list of all the groups in the tenant.

>  ***Note:** Microsoft also supports distribution groups and Mail-enabled security groups which cannot be managed or retrieved through Microsoft Graph.*

Groups functionality is limited in Cross Counter because the Microsoft Graph PowerShell module is limited in its scope. Not all 'groups' listed in the menu will be directly editable.

-  ### Enter the number listed next to the group to edit it
Leads to the `MEMBERS MENU` for the specified group
-  ### q
Returns to *Main Menu*

## 'Members' Menu
The `MEMBERS MENU` is accessible through the `GROUPS MENU` and is contxtual to a chosen group. It is presented alongside a list of members within the group.
- ### Enter the number listed next to the member...
Takes you to the *Edit User* page for the chosen group member. When you exit the user page, you will return to the Members menu.
- ### add
Presents a list of users who are not already in the group. Users can be added to the group from this list.
- ### remove
Refreshes the group's member list and enables you to pick a user to be removed from the group.
- ### q
Returns to *Groups Menu*

## More info:

**What scopes does Cross Counter use to connect?**

>` Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","RoleManagement.ReadWrite.Directory","GroupMember.ReadWrite.All","Directory.ReadWrite.All","Directory.ReadWrite.All","UserAuthenticationMethod.ReadWrite.All",Calendars.ReadWrite.Shared`