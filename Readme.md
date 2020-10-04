# Quick-Package Module 
## A Powershell Command-Packaging Module
### What is it?
Quick-Package allows you to quickly package Commands to be used in all of your Powershell Terminal Sessions

It lets you do this by providing a CLI to easily create and manage your own custom functions and Aliases. Better yet, it manages them in the form of Modules, so you can build a module and then publish it when you feel it's ready.

### How does it work?
This is a module with the psd1 file. Since it's a psd1 file it automatically adds all exported members to your Powershell Path. The first time you use one of the functions it will import the module for you. This way you can always use your function in the terminal window.

### How do I use it?
__**The following Function will show you all the available Quick-Commands:**__
Get-Module QuickModuleCLI should eventually show you all the exported members. Don't know why it's not yet. This section is a work in progress.

Once the Help Documentation has been completed, you will be able to run 'Get-Help Add-QuickAlias' for example to see a description of what the function does.

## Roadmap
* Document all of the built-in functions. 
* After the Documentation is completed then the How do I use documentation needs to be updated, and it will make it easier to understand the commands
* Add Pester Unit Tests
* Do another pass-through at ConvertTo-PowershellEncodedString to make sure it's tested, documented and completely accurate
* Edit this to no longer use $PSScriptRoot, and instead use injected functions private to this Module
* Re-write this so that instead of adding a QuickFunction, you're creating a QuickModule, and adding to the QuickModule. This way you can Publish-QuickModule
* Figure out what to do with Utility Belt. I'm not sure I like it in this module.
* Add the creation of a psd1 file to the Add-QuickModule command.
* Add a Update-QuickModule function that Updates the psd1 file with the latest and greatest exports and aliases.
* Add the Export-QuickModule command that moves the module from the Modules directory into the $Profile\Modules Directory. The point of this is when you're ready to publish a package, you should probably disassemble this from your QuickModule