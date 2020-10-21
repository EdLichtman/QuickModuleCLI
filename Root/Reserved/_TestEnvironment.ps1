function Get-SandboxBaseFolder { return "$PSScriptRoot\..\..\Tests\Sandbox"; }
function Get-SandboxNestedModulesFolder { return "$(Get-SandboxBaseFolder)\Modules"; }
function Get-SandboxFunctionsFolder { return "$(Get-SandboxBaseFolder)\Root"; }
function Get-SandboxPrivateFunctionsFolder { return "$(Get-SandboxFunctionsFolder)\Reserved" }
function Add-TestModule {
    param(
        [String] $Name,
        [Switch] $IncludeManifest,
        [Switch] $IncludeRoot
    )

    $TestModuleDirectory = "$(Get-SandboxNestedModulesFolder)\$Name"
    New-Item -Path $TestModuleDirectory -ItemType Directory
    if ($IncludeManifest) {
        $TestModuleManifest = "$TestModuleDirectory\$Name.psd1"
        New-Item -Path $TestModuleManifest
    }

    if ($IncludeRoot) {
        $TestModuleRoot = "$TestModuleDirectory\$Name.psm1"
        New-Item -Path $TestModuleRoot
    }
}

#BeforeEach
function New-Sandbox {
    New-Item -Path (Get-SandboxBaseFolder) -ItemType Directory
    New-Item -Path (Get-SandboxNestedModulesFolder) -ItemType Directory 
    New-Item -Path (Get-SandboxFunctionsFolder) -ItemType Directory
    New-Item -Path (Get-SandboxPrivateFunctionsFolder) -ItemType Directory
}

#AfterEach
function Remove-Sandbox {
    $SandboxBase = Get-SandboxBaseFolder
    if (![String]::IsNullOrWhiteSpace($SandboxBase)) {
        if (Test-Path $SandboxBase) {
            Remove-Item -Path $SandboxBase -Recurse -Force
        }
    } else {
        throw 'Scoping Exception! Get-SandboxBaseFolder is empty!'
    }
}