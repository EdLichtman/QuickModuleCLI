describe 'Get-ModuleProject' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\UI.ps1"
        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"

        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Add-ModuleFunction.ps1"
        . "$PSScriptRoot\Add-ModuleAlias.ps1"
        . "$PSScriptRoot\Get-ModuleProject.ps1"

        $ViableModule = "Viable"
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Update-ModuleProject
        Mock Import-Module
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Teardown-Sandbox
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for ModuleProject' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName ModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }

    }
    describe 'functionality' {
        it 'Should get names of all functions' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject

            $FunctionName -in $Project.Function | Should -BeTrue
            $OtherFunctionName -in $Project.Function | Should -BeTrue
        }
    
        it 'Should get names of all functions within ModuleProject' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule

            $FunctionName -in $Project.Function | Should -BeTrue
            $OtherFunctionName -in $Project.Function | Should -BeFalse
        }

        it 'Should get CommandType of all Commands within ModuleProject' {
            $FunctionName = 'Write-Foo'
            $AliasName = 'Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule

            $FunctionName -in $Project.Function | Should -BeTrue
            $AliasName -in $Project.Alias | Should -BeTrue
        }

        it 'Should get ModuleProject for each Command within ModuleProject' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject

            $ViableModule -in $Project.Name | Should -BeTrue
            'Test' -in $Project.Name | Should -BeTrue
        }

        it 'Should not get ModuleProject that is not specified if ModuleProject is specified' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule

            $ViableModule -in $Project.Name | Should -BeTrue
            'Test' -in $Project.Name | Should -BeFalse
        }
    }
    
}