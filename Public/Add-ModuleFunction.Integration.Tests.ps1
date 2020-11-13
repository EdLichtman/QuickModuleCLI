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
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.Exceptions.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"

        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Edit-ModuleCommand.ps1"
        . "$PSScriptRoot\Add-ModuleFunction.ps1"

        $ViableModule = "Viable"
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Edit-ModuleCommand -RemoveParameterValidation 'ModuleProject', 'CommandName'
        Mock Update-ModuleProject
        Mock Import-Module
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'Validation' {
        it 'throws error if ModuleProject is null or empty' {
            $err = { Add-ModuleFunction -ModuleProject '' -FunctionName 'Write-Test' -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if Module does not exist' {
            $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Test' -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if FunctionName is null or empty' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName '' -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if function already exists' {
            $FunctionName = 'Write-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName

            $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
        }
    
        it 'throws error if function does not use an approved verb' {
            $FunctionName = 'Foo-Bar'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello"' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ParameterStartsWithUnapprovedVerbException'
        }
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid verb arguments for FunctionName' {
            $Arguments = (Get-ArgumentCompleter -CommandName Add-ModuleFunction -ParameterName FunctionName)
            
            'Get-' -in ($Arguments.Definition.Invoke()) | Should -BeTrue
        }
    }
    describe 'functionality' {
        it 'Should create a function located in a module' {
            $FunctionName = 'Write-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeTrue
        }
    
        it 'Should create a function' {
            $FunctionName = 'Write-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName
    
            $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
            . "$FunctionPath"
    
            $Function = Get-Item "function:\$FunctionName"
            $Function.Definition.Trim() | Should -Be ''
        }
    
        it 'Should create a function with a non-standard value text' {
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
    
        it 'Should try to import the module again' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Get-Foo'
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Force -eq $True -and $Name -eq $BaseModuleName}
        }
    
        it 'attempts to edit-modulecommand if functionText is not provided' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -WhatIf
            
            Assert-MockCalled Edit-ModuleCommand -Times 1
        }
    
        it 'does not edit-modulecommand if functionText is provided' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
            Assert-MockCalled Edit-ModuleCommand -Times 0
        }
    
        it 'splits strings into new lines on semicolon' {
            #Mock for the sake of assertion, but you need to still return a value to work.
            Mock SemicolonCreatesLineBreakTransformation {param($inputData) return $inputData} 
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
            Assert-MockCalled SemicolonCreatesLineBreakTransformation -Times 1
        }

        it 'Should try to update the ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $ViableModule}
        }

        it 'Should try to re-import the ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True}
        }
    }
    
}