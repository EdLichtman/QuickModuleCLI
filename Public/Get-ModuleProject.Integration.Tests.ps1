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
        Remove-Sandbox
    }
<#[String] $ModuleProject,
[String] $CommandName,
[Switch] $Summary#>
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for ModuleProject' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        # it 'auto-suggests valid Commands if ModuleProject is provided' {

        # }

        # it 'auto-suggests valid Commands if ModuleProject is not provided' {

        # }
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

            $FunctionName -in $Project.Command | Should -BeTrue
            $OtherFunctionName -in $Project.Command | Should -BeTrue
        }
    
        # it 'Should create a function' {
        #     $FunctionName = 'Write-Foo'
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName
    
        #     $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
        #     . "$FunctionPath"
    
        #     $Function = Get-Item "function:\$FunctionName"
        #     $Function.Definition.Trim() | Should -Be ''
        # }
    
        # it 'Should create a function with a non-standard value text' {
        #     $expectedReturnValue = 'Foo'
        #     $FunctionName = 'Get-Foo'
        #     $FunctionText = "return '$expectedReturnValue'"
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
    
        #     $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
        #     . "$FunctionPath"
    
        #     $actualReturnValue = Invoke-Expression "$FunctionName"
        #     $actualReturnValue | Should -Be $expectedReturnValue
        # }
    
        # it 'attempts to edit-modulecommand if functionText is not provided' {
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -WhatIf
            
        #     Assert-MockCalled Edit-ModuleCommand -Times 1
        # }
    
        # it 'does not edit-modulecommand if functionText is provided' {
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
        #     Assert-MockCalled Edit-ModuleCommand -Times 0
        # }
    
        # it 'splits strings into new lines on semicolon' {
        #     #Mock for the sake of assertion, but you need to still return a value to work.
        #     Mock SemicolonCreatesLineBreakTransformation {param($inputData) return $inputData} 
    
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
        #     Assert-MockCalled SemicolonCreatesLineBreakTransformation -Times 1
        # }

        # it 'Should try to update the ModuleProject' {
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
        #     Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $ViableModule}
        # }

        # it 'Should try to re-import the ModuleProject' {
        #     Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        #     Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
        #     Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        # }
    }
    
}