describe 'Move-ModuleCommand' {
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
        . "$PSScriptRoot\Move-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Import-Module
        Mock Update-ModuleProject
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Teardown-Sandbox
    }

    describe 'validations' {
        it 'throws error if source ModuleProject does not exist' {   
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if CommandName is null' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName '' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if function does not exist in source ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
        it 'throws error if Destination ModuleProject is null' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'

            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject '' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if destination ModuleProject does not exist' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
    
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
        it 'throws error if source ModuleProject is same as destination ModuleProject' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
    
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandMoveDestinationIsInvalidException'
        }
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Source Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName SourceModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'SourceModuleProject'=$ViableModule}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestAlias $ViableModule 'Bar'
            Add-TestModule 'Test' -Valid
            Add-TestFunction 'Test' 'Get-Foo'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Foo-Bar','Bar')
        }

        it 'auto-suggests valid Module Command for CommandName with no SourceModuleProject' {
            $FakeBoundParameters = @{}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestModule 'Test' -Valid
            Add-TestAlias 'Test' 'Bar'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Bar','Foo-Bar')
        }

        it 'auto-suggests valid Module Arguments for Destination Module' {
            Add-TestModule $ViableModule -Valid
            Add-TestModule 'Test' -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName DestinationModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @('Test',$ViableModule)
        }
    }
    describe 'functionality' {
        it 'moves command into destination module if function' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject 'Test' -CommandName $FunctionName) | Should -BeTrue
        }
    
        it 'moves command into destination module if alias' {
            $Alias = 'Foo'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $Alias
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $Alias -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject 'Test' -CommandName $Alias) | Should -BeTrue
        }
    
        it 'removes command from source module if function' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeFalse
        }
        
        it 'removes command from source module if alias' {
            $Alias = 'Foo'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $Alias
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $Alias -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $Alias) | Should -BeFalse
        }
        
        it 'attempts to update sourceModuleProject with removed Function or alias' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $DestinationModule = 'Test'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $DestinationModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $DestinationModule
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $ViableModule}
        }
    
        it 'attempts to update DestinationModuleProject with new Function or alias' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $DestinationModule = 'Test'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $DestinationModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $DestinationModule
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $DestinationModule}
        }
    
        it 'Should try to re-import the ModuleProject' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $DestinationModule = 'Test'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $DestinationModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $DestinationModule
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        }        

        it 'moves command into destination module if no SourceModuleProject is provided' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -Valid
            Add-TestModule -Name 'Test' -Valid
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -CommandName $FunctionName -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject 'Test' -CommandName $FunctionName) | Should -BeTrue
        }

        it 'moves entire function including Argument completers and anything else' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "param([String]`$foo)`nreturn `$foo"

            Add-TestModule -Name $ViableModule -Valid
            Add-TestModule -Name 'Test' -Valid
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
            $BeforeFunction = "`$Foo = 'Bar'"
            $AfterFunction = "Register-ArgumentCompleter -CommandName $FunctionName -ParameterName foo -ScriptBlock {return 'a'}"
            $FunctionFilePath = (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName)
            $Output = @($BeforeFunction) + @(Get-Content $FunctionFilePath ) + @($AfterFunction)
            [IO.File]::WriteAllText($FunctionFilePath, $Output -join "`n" ,[Text.Encoding]::UTF8)
            
            Move-ModuleCommand -CommandName $FunctionName -DestinationModuleProject 'Test'
    
            $Content = Get-Content (Get-ModuleProjectFunctionPath -ModuleProject 'Test' -CommandName $FunctionName)

            $FirstLine = $Content[0]
            $FirstLine | Should -Be $BeforeFunction
            $LastLine = $Content[$Content.Length -1] 
            $LastLine | Should -Be $AfterFunction
        } 
    }

}