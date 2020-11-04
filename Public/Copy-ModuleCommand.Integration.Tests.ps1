describe 'Copy-ModuleCommand' {
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
        . "$PSScriptRoot\Add-ModuleAlias.ps1"
        . "$PSScriptRoot\Edit-ModuleCommand.ps1"
        . "$PSScriptRoot\Copy-ModuleCommand.ps1"

        $ViableModule = "Viable"
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Edit-ModuleCommand
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    it 'Should copy a function to a new function in the same module' {
        $FunctionName = 'Write-Foo'
        $FunctionText = "return 'Foo'"
        $NewFunctionName = 'Write-FooClone'

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $FunctionName -DestinationModuleProject $ViableModule -DestinationCommandName $NewFunctionName

        Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName) | Should -BeTrue
    }

    it 'Should copy a function to a new function in a different module' {
        $FunctionName = 'Write-Foo'
        $FunctionText = "return 'Foo'"
        $NewModuleName = 'Test'
        $NewFunctionName = 'Write-FooClone'

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-TestModule -Name $NewModuleName -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $FunctionName -DestinationModuleProject $NewModuleName -DestinationCommandName $NewFunctionName

        Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $NewModuleName -CommandName $NewFunctionName) | Should -BeTrue
    }

    it 'Should copy an alias to a new alias in the same module' {
        $AliasName = 'Foo'
        $AliasMappedFunction = "Write-Output"
        $NewAliasName = 'FooClone'

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction

        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $AliasName -DestinationModuleProject $ViableModule -DestinationCommandName $NewAliasName

        Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $NewAliasName) | Should -BeTrue
    }

    it 'Should copy an alias to a new alias in a differentmodule' {
        $AliasName = 'Foo'
        $AliasMappedFunction = "Write-Output"
        $NewModuleName = 'Test'
        $NewAliasName = 'FooClone'

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-TestModule -Name $NewModuleName -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction

        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $AliasName -DestinationModuleProject $NewModuleName -DestinationCommandName $NewAliasName

        Test-Path (Get-ModuleProjectAliasPath -ModuleProject $NewModuleName -CommandName $NewAliasName) | Should -BeTrue
    }

    it 'Should create a function with the same definition as its source' {
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        $FunctionName = 'Get-Foo'
        $FunctionText = "return 'Foo'"
        $NewFunctionName = 'Get-FooClone'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $FunctionName -DestinationModuleProject $ViableModule -DestinationCommandName $NewFunctionName

        $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
        $CopiedFunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName
        
        . "$FunctionPath"
        . "$CopiedFunctionPath"

        $CommandType, $Definition = Get-ModuleProjectCommandDefinition -ModuleProject $ViableModule -CommandName $FunctionName
        $CopiedCommandType, $CopiedDefinition = Get-ModuleProjectCommandDefinition -ModuleProject $ViableModule -CommandName $NewFunctionName

        $Definition | Should -Be $FunctionText
        $CopiedDefinition | Should -Be $Definition
        $CopiedCommandType | Should -Be 'Function'
    }
}