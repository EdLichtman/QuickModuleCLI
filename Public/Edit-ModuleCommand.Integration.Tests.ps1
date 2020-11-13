describe 'Edit-ModuleCommand' {
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
        . "$PSScriptRoot\..\Private\Validators.Exceptions.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"

        . "$PSScriptRoot\Add-ModuleFunction.ps1"
        . "$PSScriptRoot\Edit-ModuleCommand.ps1"

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

    it 'Attempts to Open Powershell Editor' {
        $FunctionName = 'Write-Foo'
        $FunctionText = "return 'Foo'"

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

        Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName
        
        Assert-MockCalled Open-PowershellEditor -Times 1
    }

    it 'Attempts to Open Powershell Editor' {
        $FunctionName = 'Write-Foo'
        $FunctionText = "return 'Foo'"

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

        Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName
        
        Assert-MockCalled Wait-ForKeyPress -Times 1
    }
}