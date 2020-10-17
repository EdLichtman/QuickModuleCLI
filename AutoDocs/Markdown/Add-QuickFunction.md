---
external help file: QuickModuleCLI-help.xml
Module Name: QuickModuleCLI
online version: https://github.com/EdLichtman/QuickModuleCLI
schema: 2.0.0
---

# Add-QuickFunction

## SYNOPSIS
Adds a function to a QuickModuleCLI nested module.

## SYNTAX

```
Add-QuickFunction [-NestedModule] <String> [-FunctionName] <String> [[-FunctionText] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds a function to a QuickModuleCLI nested module that can later be auto-loaded based on your $PSModuleAutoLoadingPreference.

## EXAMPLES

### EXAMPLE 1
```
Add-QuickFunction -NestedModule Default -functionName Write-Echo -functionText 'Write-Output (Read-Host "Are you my echo?")'
```

### EXAMPLE 2
```
Add-QuickFunction Default Write-Echo 'Please enter the Function: Write-Output (Read-Host "Are you my echo?")'
```

### EXAMPLE 3
```
Add-QuickFunction Default Write-Echo
```

\[PS ISE opens...\]
Press any key when you are finished editing...

## PARAMETERS

### -FunctionName
Specifies the name of the new function

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FunctionText
Specifies the content that should go in the function.
Line breaks will automatically 
be added after semi semicolons.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NestedModule
Specifies the name of the NestedModule in which this function belongs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Add-QuickFunction.
## OUTPUTS

### None. Add-QuickFunction creates a new function that you can later use.
## NOTES
Once created, every time you open a new Powershell window the function will be exported for you to use.
Once you attempt to use a function for the first time
in a powershell session it will auto-import the rest of the module for you.

If you use this function with the $functionText parameter, then your function will be automatically formatted with line breaks, wherever you had included semi-colons (;).
Additionally, if you do not include the $functionText parameter, then this function will open your Powershell ISE for you to modify the function there.

## RELATED LINKS

[https://github.com/EdLichtman/QuickModuleCLI](https://github.com/EdLichtman/QuickModuleCLI)

