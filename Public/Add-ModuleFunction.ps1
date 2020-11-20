# .ExternalHelp ..\AutoDocs\ExternalHelp\QuickModuleCLI-Help.xml
function Add-ModuleFunction {
    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [string] $ModuleProject,

        # [Parameter(Mandatory=$true)]
        # [ValidateNotNullOrEmpty()]
        # [ValidateScript({ValidateModuleCommandDoesNotExist $_})]
        # [ValidateScript({ValidateCommandStartsWithApprovedVerb $_})]
        # [string] $FunctionName,

        [Parameter(Mandatory=$false)]
        [string] 
        $FunctionText,

        [Parameter()]
        [Switch]$Force
    )
    DynamicParam {
        $attribute = New-Object System.Management.Automation.ParameterAttribute
        $attribute.Mandatory = $true

        $collection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $collection.Add($attribute)

        $collection.Add((New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute))
        $collection.Add((New-Object System.Management.Automation.ValidateScriptAttribute({ValidateModuleCommandDoesNotExist $_})))  
        if (!$Force) {
            $collection.Add((New-Object System.Management.Automation.ValidateScriptAttribute({ValidateCommandStartsWithApprovedVerb $_})))  
        } 

        $param = New-Object System.Management.Automation.RuntimeDefinedParameter('FunctionName', [string], $collection)
        $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $dictionary.Add('FunctionName', $param)  

        return $dictionary
    }
    Begin {
        $FunctionName = $PSBoundParameters['FunctionName']
    }
    process {
        New-ModuleProjectFunction -ModuleProject $ModuleProject -CommandName $FunctionName -Text (SemicolonCreatesLineBreakTransformation $FunctionText)

        if ([String]::IsNullOrWhiteSpace($FunctionText)) {
            Edit-ModuleCommand -ModuleProject $ModuleProject -CommandName $FunctionName
        }
    
        Update-ModuleProject -ModuleProject $ModuleProject
        Import-Module $BaseModuleName -Force -Global
    }
}
Register-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName ModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName FunctionName -ScriptBlock (Get-Command ApprovedVerbsArgumentCompleter).ScriptBlock