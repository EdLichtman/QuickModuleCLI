Describe 'Install-QuickPackage' {
    BeforeAll {
        $UnderTest = $true
        $ValidatingImports = $false
        . ".\Required\Reserved\Import-TestHeader.ps1"
        Mock Remove-QuickUtilityBelt
        Mock Remove-QuickPackage
        Mock Add-QuickPackage
        Mock Add-QuickPackageToProfile
        Mock Add-QuickUtility
    }

    It "does nothing if no flag is called" {
        Install-QuickPackage
        Assert-MockCalled Remove-QuickUtilityBelt -Times 0
        Assert-MockCalled Remove-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackageToProfile -Times 0
        Assert-MockCalled Add-QuickUtility -Times 0
        
    }

    It "Uninstalls QuickPackage if Uninstall flag is called" {
        Install-QuickPackage -Uninstall
        Assert-MockCalled Remove-QuickPackage -Times 1
    }

    It "Uninstall QuickPackageUtility if Uninstall flag is called" {
        Install-QuickPackage -Uninstall
        Assert-MockCalled Remove-QuickUtilityBelt -Times 1
    }

    It "Does not install anything if Uninstall flag is called" {
        Install-QuickPackage -Uninstall
        Assert-MockCalled Add-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackageToProfile -Times 0
        Assert-MockCalled Add-QuickUtility -Times 0
    }

    It "Successfully imports all files" {
        $ValidatingImports = $true

        # Should throw AssertionError if any Imports are missing
        Install-QuickPackage
    }
}

