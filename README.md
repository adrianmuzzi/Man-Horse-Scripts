# Man-Horse-Scripts
I plan for this to  be a repository of Powershell scripts I have developed to shave milliseconds off of the time it takes me to do something at work.
They are all named for Melbourne Cup winners.

# Cross Counter 1.1

Cross Counter is for making fast changes to users in a Microsoft 365 tenant. It utilises the MgGraph powershell module. If you do not have this module, it will prompt you for install.

A web browser will then be launched with a Microsoft login prompt. 
## Main menu commands

The `MAIN MENU` is the highest level menu in Cross Counter. Upon first singing into the tenant with Cross Counter, you are prompted with a fresh user list and this main menu.

-  ### Enter the number listed next to the user you wish to edit
 Leads to the *Edit User* menu for the user selected from the user list.

- ### all
Leads to the *edit all users* menu.

- ### groups
Leads to the *Groups Menu*.

- ### users
This refreshes and re-displays the user list. Note that if changes are made to a user's display name- this may lead to changes in the list ordering (as it is organised alphabetically). Whenever you select a user from the user list,  the 'number' you input to do so is always relevant to the most recent time the user list has been refreshed and displayed.

- ### off
This is still under construction and calling it is not recommended. It is planned that this will take the selected user through an automated 'employee off boarding' process. *Be careful when using this command*.

- ### q
'q' In the main menu will sign out of MgGraph and exit powershell.

## 'Edit User' menu
This menu allows for quick changes to a chosen user in the tenant.
- [1] Display Name*
- [2] First Name*
- [3] Last Name*
- [4] Job Title*
- [5] Mobile Phone*
- [6] Department
- [7] Street address
- [8] City
- [9] Postal Code
- [10] Country
- [11] Company Name
- [12] Remove from Group^

**shows preview* *^curently broken*
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
The `GROUPS MENU` is presented after a list of all the groups in the tenant.
-  ### Enter the number listed next to the group to edit it
Lists the users in a group. Entering a user's number takes you to the edit user menu. Other funtionality is currently broken.
-  ### Create a new group
Broken.
-  ### q
Returns to *Main Menu*

## Off Boarding
Currently this will generate a random password and assign it to the user. Functionality beyond that is broken.

## More info:

**What scopes does Cross Counter use to connect?**

>` Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All","UserAuthenticationMethod.ReadWrite.All" `
