describe 'Add-ModuleAlias' {
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
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    it 'Should create a function located in a module' {
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        $FunctionName = 'Write-Foo'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName

        Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeTrue
    }

    it 'Should create a function' {
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        $FunctionName = 'Write-Foo'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName

        $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
        . "$FunctionPath"

        $Function = Get-Item "function:\$FunctionName"
        $Function.Definition.Trim() | Should -Be ''
    }

    it 'Should create a function with a non-standard value text' {
        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        $expectedReturnValue = 'Foo'
        $FunctionName = 'Get-Foo'
        $FunctionText = "return '$expectedReturnValue'"
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText

        $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
        . "$FunctionPath"

        $actualReturnValue = Invoke-Expression "$FunctionName"
        $actualReturnValue | Should -Be $expectedReturnValue
    }
}