# Quick-Package Module 
## A Powershell Command-Packaging Module
### What is it?
Quick-Package allows you to quickly package Commands to be used in all of your Powershell Terminal Sessions
### How does it work?
The '$Profile' variable in Powershell hosts a script that will be run every time you open a Powershell Terminal. 

Quick-Package is a Module that gets added into your '$Profile', and makes available to you all of the Quick-Package Functions. These functions let you easily package your own Commands into the Quick-Package Module. Then, every time a new window is loaded, those Commands you've created will be available to you.

### How do I use it?
__**The following Function will show you all the available Quick-Commands:**__
Get-QuickCommands 

__**The following Functions allow you to Add a command:**__
* Add-QuickAlias
* Add-QuickFunction
* Add-QuickFunctionWithEditor
* Add-QuickTool 

__**The following Functions will allow you to alter an existing command:**__
* Edit-QuickCommand
* Rename-QuickCommand

__**The following Functions will allow you to remove an existing command. You can only remove UserDefined Quick Commands, or Utility Belt Quick-Commands:**__
* Remove-QuickCommand

__**The following are utility functions:**__
* Set-QuickToolsPath
* Export-QuickCommand
* Refresh-QuickCommand

__**The following are installed with the Utility Belt. The Utility Belt can be installed on a per Function basis:**__
* Add-Reminder (Sets a Scheduled Task to alert you after a pre-defined time period)
* Show-CommandContent (Prints out to the screen the Function Definition. Would be nice to colorize the text)
* * read (The Alias for Define-Command)
* Get-DiskInfo (Prints out to the screen Information about your Disk such as Free Space and Total Space in GB)
* Get-RealtimeFileContents (Just a Wrapper for Get-Content -Wait)
* * tail (The Alias for Tail-File. The only reason I included Tail-File. This is if you're used to using Linux tail command)
* Set-Env (sets environment variable)
* Find-Desktop (Uses Powershell logic to get the Desktop of the profile an goes to it)

* Aliases Unmapped to functions
* * edit (The Alias for Edit-Command)

Once the Help Documentation has been completed, you will be able to run 'Get-Help Add-QuickAlias' for example to see a description of what the function does.

## Roadmap
* I need to learn a bit more about CMDLET, and once I understand them, I need to Add-QuickCmdlet
* Complete Export-QuickCommand to create a script that, when run, will import into the Quick-Package Module
* Clean up the Get-QuickModules printout. 
* Move Install, Uninstall and Install-UtilityBelt to also be reserved, and expose a new function: Uninstall-QuickPackage, Install-Utility, Install-UtilityBelt
* Document all of the built-in functions. 
* After the Documentation is completed then the How do I use documentation needs to be updated, and it will make it easier to understand the commands
* I need to rebuild the Alias Mapping to get created and passed around on startup, so that Rename-Function and Remove-Function will also affect the Aliases
* Cleanup. Always cleanup.
* Adding more tools to the Utility Belt would be nice
* Add the ability to "Add New Profile" without re-installing the whole thing. 
* Install-Script should be a function that gets run on the RunMe, as well as uninstall and install-UtilityBelt stuff
* Add Pester Unit Tests

