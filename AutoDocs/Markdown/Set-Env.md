---
external help file: QuickModuleCLI-help.xml
Module Name: QuickModuleCLI
online version: https://github.com/EdLichtman/Quick-Package
schema: 2.0.0
---

# Set-Env

## SYNOPSIS
Adds a system or user variable.

## SYNTAX

```
Set-Env [[-variable] <String>] [[-value] <String>] [[-environmentVariableTarget] <EnvironmentVariableTarget>]
 [<CommonParameters>]
```

## DESCRIPTION
This function is a wrapper around the \[Environment\]::SetEnvironmentVariable function.
It first checks to see if the environment 
variable exists, then asks if you wish to overwrite it.

## EXAMPLES

### EXAMPLE 1
```
Set-Env
```

Please enter Environment Variable Name: Desktop
Please enter Environment Variable Value: C:\Users\User\Path-To-Desktop
PS C:\\\>
...
PS C:\\\>Set-Location $env:Desktop
PS C:\Users\User\Path-To-Desktop\>

### EXAMPLE 2
```
Set-Env -variable Desktop -value C:\Users\User\Path-To-Desktop
```

PS C:\\\>
...
PS C:\\\>Set-Location $env:Desktop
PS C:\Users\User\Path-To-Desktop\>

### EXAMPLE 3
```
Set-Env -variable Desktop -value C:\Users\User\Path-To-Desktop
```

A value already exists for the User variable 'Desktop'
Would you like to overwrite?
\[Y\] Yes  \[N\] No  \[?\] Help (default is "N"):Y
PS C:\\\>
...
PS C:\\\>Set-Location $env:Desktop
PS C:\Users\User\Path-To-Desktop\>

### EXAMPLE 4
```
Set-Env -variable MyApplication -value "C:\Program Files\Path-To-My-Application" -environmentVariableTarget "Machine"
```

PS C:\\\>
...
PS C:\\\>Set-Location $env:MyApplication
PS C:\Program Files\Path-To-My-Application\>

## PARAMETERS

### -environmentVariableTarget
{{ Fill environmentVariableTarget Description }}

```yaml
Type: EnvironmentVariableTarget
Parameter Sets: (All)
Aliases:
Accepted values: Process, User, Machine

Required: False
Position: 3
Default value: User
Accept pipeline input: False
Accept wildcard characters: False
```

### -value
{{ Fill value Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -variable
{{ Fill variable Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Set-Env
## OUTPUTS

### None. Set-Env creates environment configuration that you can later use.
## NOTES
\[EnvironmentVariableTarget\] can be interpreted from the strings "User" or "Machine"

## RELATED LINKS

[https://github.com/EdLichtman/Quick-Package](https://github.com/EdLichtman/Quick-Package)

