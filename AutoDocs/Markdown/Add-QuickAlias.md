---
external help file: QuickModuleCLI-help.xml
Module Name: QuickModuleCLI
online version: https://github.com/EdLichtman/QuickModuleCLI
schema: 2.0.0
---

# Add-QuickAlias

## SYNOPSIS
Adds an alias to a QuickModuleCLI nested module.

## SYNTAX

```
Add-QuickAlias [-NestedModule] <String> [-AliasName] <String> [-AliasMappedFunction] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Adds an alias to a QuickModuleCLI nested module that can later be auto-loaded based on your $PSModuleAutoLoadingPreference.

## EXAMPLES

### EXAMPLE 1
```
Add-QuickAlias -NestedModule Default -AliasName echo -AliasMappedFunction 'Write-Output'
```

### EXAMPLE 2
```
Add-QuickAlias Default echo Write-Output
```

## PARAMETERS

### -AliasMappedFunction
Specifies the name of the function to which this alias maps.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AliasName
Specifies the name of the new alias.

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

### None. You cannot pipe objects to Add-QuickAlias.
## OUTPUTS

### None. Add-QuickAlias creates a new alias that you can later use.
## NOTES
Once created, every time you open a new Powershell window the alias will be exported for you to use.
Once you attempt to use an alias for the first time
in a powershell session it will auto-import the rest of the module for you.

## RELATED LINKS

[https://github.com/EdLichtman/QuickModuleCLI](https://github.com/EdLichtman/QuickModuleCLI)

