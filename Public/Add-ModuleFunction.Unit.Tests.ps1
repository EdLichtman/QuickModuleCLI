describe 'Add-ModuleFunction' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"
        
        . "$PSScriptRoot\Add-ModuleFunction.ps1"

        $ViableModule = "Viable"
    }

    it 'throws error if module does not exist' {
        Mock Get-ValidModuleProjectNames { return @() }
        $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Test' -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }

    it 'throws error if function already exists' {
        $Function = 'Write-Foo'
        $MockFunctionFile = Get-MockFileInfo -BaseName $Function

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @($MockFunctionFile) }
        Mock Get-ModuleProjectAliases { return @()}

        $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $Function -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
    }

    it 'throws error if function does not use an approved verb' {
        $Function = 'Foo-Bar'

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $Function -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ParameterStartsWithUnapprovedVerbException'
    }

    it 'Attempts to create a new ModuleProjectFunction' {
        Mock New-ModuleProjectFunction
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Mock Get-ValidModuleProjectNames { return ($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello"' -WhatIf

        Assert-MockCalled New-ModuleProjectFunction -Times 1
    }

    it 'Attempts to open the powershell editor if no text is entered' {
        Mock New-ModuleProjectFunction
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -WhatIf
        
        Assert-MockCalled Open-PowershellEditor -Times 1
    }

    it 'does not attempts to open the powershell editor if text is entered' {
        Mock New-ModuleProjectFunction
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf

        Assert-MockCalled Open-PowershellEditor -Times 0
    }

    it 'waits for keypress input if no text is entered' {
        Mock New-ModuleProjectFunction
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -WhatIf
        
        Assert-MockCalled Wait-ForKeyPress -Times 1
    }

    it 'does not wait for keypress input if text is entered' {
        Mock New-ModuleProjectFunction
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    

        Assert-MockCalled Wait-ForKeyPress -Times 0
    }

    it 'splits strings into new lines on semicolon' {
        Mock New-ModuleProjectFunction
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress
        
        #Mock for the sake of assertion, but you need to still return a value to work.
        Mock Get-SemicolonCreatesLineBreakTransformation {param($inputData) return $inputData} 

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @() }
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf

        Assert-MockCalled Get-SemicolonCreatesLineBreakTransformation -Times 1
    }

    it 'auto-suggests valid verb arguments for FunctionName' {
        $Arguments = (Get-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName FunctionName)
        
        $Arguments.Definition.Ast.Name | Should -Be Get-ApprovedVerbsArgumentCompleter
    }

    it 'auto-suggests valid Module Arguments for Module' {
        $Arguments = (Get-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName ModuleProject)
        
        $Arguments.Definition.Ast.Name | Should -Be Get-ModuleProjectArgumentCompleter
    }
}