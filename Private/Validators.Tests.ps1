Describe 'Validators' {
    BeforeAll {
        . "$PSScriptRoot\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        $ViableModule = "Viable"
        $NonviableModule = "Nonviable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'

        . "$PSScriptRoot\Environment.ps1"
        . "$PSScriptRoot\ArgumentCompleters.ps1"
        . "$PSScriptRoot\Validators.ps1"

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
    Describe 'ValidateModuleProjectExistsAttribute' {
        BeforeEach {
            function Test-ModuleProjectExistsFunction{
                param(
                    [ValidateModuleProjectExistsAttribute()]
                    [String]
                    $ModuleProject
                )
            }
        }

        it 'Errors if module is empty string (because be default empty module does not exist)' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleProjectExistsFunction -ModuleProject "" } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Errors if no modules exist' {
            { Test-ModuleProjectExistsFunction -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Errors if Module does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleProjectExistsFunction -ModuleProject $NonViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Does not error if Module is valid' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleProjectExistsFunction -ModuleProject $ViableModule } | Should -Not -Throw -ExceptionType $ParameterBindingException
        }
    }

    describe 'ValidateModuleProjectDoesNotExistAttribute' {
        BeforeEach {
            function Test-ModuleProjectDoesNotExistFunction{
                param(
                    [ValidateModuleProjectDoesNotExist()]
                    [String]
                    $ModuleProject
                )
            }
        }

        it 'Does not error if no moduleProjects exist' {
            { Test-ModuleProjectDoesNotExistFunction -ModuleProject $ViableModule } | Should -Not -Throw
        }

        it 'Does not error if ModuleProject does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleProjectDoesNotExistFunction -ModuleProject $NonViableModule } | Should -Not -Throw
        }

        it 'Errors if ModuleProject already exists is valid' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleProjectDoesNotExistFunction -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Does not error if Module exists and is not a module project' {
            Mock Get-Module { return $true } # uses truthiness to validate if exists
            { Test-ModuleProjectDoesNotExistFunction -ModuleProject $ViableModule } | Should -not -Throw 
        }
    }

    describe 'ValidateModuleDoesNotExistAttribute' {
        BeforeEach {
            function Test-ModuleDoesNotExistFunction{
                param(
                    [ValidateModuleDoesNotExist()]
                    [String]
                    $ModuleProject
                )
            }
        }

        it 'Does not error if ModuleProject already exists is valid' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleDoesNotExistFunction -ModuleProject $ViableModule } | Should -not -Throw 
        }

        it 'Errors if Module exists and is not a module project' {
            Mock Get-Module { return $true } # uses truthiness to validate if exists
            { Test-ModuleDoesNotExistFunction -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }
    }

    describe 'ValidateModuleCommandExistsAttribute' {
        BeforeEach {
            function Test-ModuleCommandExistsFunction {
                param( 
                    [ValidateModuleCommandExists()]
                    [String]
                    $CommandName
                    )
            }
        }

        it 'Does not error if command exists' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo'
            { Test-ModuleCommandExistsFunction -CommandName 'Get-Foo' } | Should -Not -Throw
        }

        it 'Errors if command does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            { Test-ModuleCommandExistsFunction -CommandName 'Get-Foo' } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Errors if known command is not a module command' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            { Test-ModuleCommandExistsFunction -CommandName 'Write-Output' } | Should -Throw -ExceptionType $ParameterBindingException
        }
    }

    describe 'ValidateCommandExistsAttribute' {
        BeforeEach {
            function Test-CommandExistsFunction {
                param( 
                    [ValidateCommandExists()]
                    [String]
                    $CommandName
                    )
            }
        }

        it 'Does not error if command exists' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo'
            { Test-CommandExistsFunction -CommandName 'Get-Foo' } | Should -Not -Throw
        }

        it 'Errors if command does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            { Test-CommandExistsFunction -CommandName 'Get-Foo' } | Should -Throw
        }

        it 'Does not error if known command is not a module command' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            { Test-CommandExistsFunction -CommandName 'Write-Output' } | Should -not -Throw
        }
    }

    describe 'ValidateModuleCommandDoesNotExistAttribute' {
        BeforeEach {
            function Test-ModuleCommandDoesNotExistFunction {
                param( 
                    [ValidateModuleCommandDoesNotExist()]
                    [String]
                    $CommandName
                    )
            }
        }

        
        it 'Errors if command exists in one module' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo'
            { Test-ModuleCommandDoesNotExistFunction -CommandName 'Get-Foo' } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Errors if command exists in a different module' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName "_First" -FunctionName 'Get-Foo'
            { Test-ModuleCommandDoesNotExistFunction -CommandName 'Get-Foo' } | Should -Throw -ExceptionType $ParameterBindingException
        }


        it 'Does not error if command does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            { Test-ModuleCommandDoesNotExistFunction -CommandName 'Get-Foo' } | Should -Not -Throw 
        }
    }

    describe 'Assert-CommandExistsInModule' {
        BeforeEach {
            function Test-CommandExistsInModuleFunction {
                param( 
                    [String]
                    $ModuleProject,
                    [ValidateModuleCommandExists()]
                    [String]
                    $CommandName
                    )
                    Assert-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName
            }
        }

        it 'Errors if command does exist but not in module' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName "_First" -FunctionName 'Get-Foo'

            $err = { Test-CommandExistsInModuleFunction -ModuleProject $ViableModule -CommandName 'Get-Foo' } | Should -Throw -PassThru
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }

        it 'Does not error if function exists in Module' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo'

            { Test-CommandExistsInModuleFunction -ModuleProject $ViableModule -CommandName 'Get-Foo' } | Should -Not -Throw
        }

        
        it 'Does not error if alias exists in Module' {
            Add-TestModule -Name '_First' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName 'Foo'

            { Test-CommandExistsInModuleFunction -ModuleProject $ViableModule -CommandName 'Foo' } | Should -Not -Throw
        }

    }

    describe 'ValidateParameterStartsWithApprovedVerbAttribute' {
        BeforeEach {
            function Test-Attribute{
                param(
                    [ValidateParameterStartsWithApprovedVerb()]
                    [String]
                    $Command
                )
            }
        }
        it 'Checks if null or empty if combined' {
            function Test-AttributeWithNull{
                param(
                    [ValidateNotNullOrEmpty()]
                    [ValidateParameterStartsWithApprovedVerb()]
                    [String]
                    $Command
                )
            }

            { Test-AttributeWithNull -Command "" } | Should -Throw
        }
        it 'Does not validate if null or empty' {
            { Test-Attribute -Command "" } | Should -Not -Throw
        }

        it 'disallows unapproved verb' {
            { Test-Attribute -Command "Foo-Bar" } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'allows approved verb' {
            { Test-Attribute -Command "Test-FooBar" } | Should -Not -Throw
        }
    }
}