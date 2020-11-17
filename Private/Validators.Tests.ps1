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
    Describe 'ValidateModuleProjectExists' {
        BeforeEach {
            function Test-ModuleProjectExistsFunction{
                param(
                    [ValidateScript({ValidateModuleProjectExists $_})]
                    [String]
                    $ModuleProject
                )
            }
        }

        it 'Does not error if module is empty string (because we want to separate concerns into separate attributes)' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Test-ModuleProjectExistsFunction -ModuleProject "" } | Should -Not -Throw
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

    describe 'ValidateModuleProjectDoesNotExist' {
        BeforeEach {
            function Test-ModuleProjectDoesNotExistFunction{
                param(
                    [ValidateScript({ValidateModuleProjectDoesNotExist $_})]
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

    describe 'ValidateModuleDoesNotExist' {
        BeforeEach {
            function Test-ModuleDoesNotExistFunction{
                param(
                    [ValidateScript({ValidateModuleDoesNotExist $_})]
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

    describe 'ValidateModuleCommandDoesNotExist' {
        BeforeEach {
            function Test-ModuleCommandDoesNotExistFunction {
                param( 
                    [ValidateScript({ValidateModuleCommandDoesNotExist $_})]
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

    describe 'ValidateCommandExistsInModule' {
        BeforeEach {
            function Test-CommandExistsInModuleFunction {
                param( 
                    [String]
                    $ModuleProject,
                    [ValidateScript({ValidateModuleCommandExists $_})]
                    [String]
                    $CommandName
                    )
                    ValidateCommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName
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

    describe 'ValidateParameterStartsWithApprovedVerb' {
        BeforeEach {
            function Test-Attribute{
                param(
                    [ValidateScript({ValidateCommandStartsWithApprovedVerb $_})]
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