Describe 'Install-QuickPackage' {
    BeforeAll {
        . ".\Required\Reserved\Get-TestHeaders.ps1"
        . ".\Install-QuickPackage.ps1"
    }

    It "does nothing if no flag is called" {
        Invoke-Expression (Get-MockImportsHeader)
        Mock Remove-QuickUtilityBelt
        Mock Remove-QuickPackage
        Mock Add-QuickPackage
        Mock Add-QuickPackageToProfile
        Mock Add-QuickUtility

        Install-QuickPackage
        Assert-MockCalled Remove-QuickUtilityBelt -Times 0
        Assert-MockCalled Remove-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackageToProfile -Times 0
        Assert-MockCalled Add-QuickUtility -Times 0
        
    }

    It "Uninstalls QuickPackage if Uninstall flag is called" {
        Invoke-Expression (Get-MockImportsHeader)
        Mock Remove-QuickUtilityBelt
        Mock Remove-QuickPackage
        Mock Add-QuickPackage
        Mock Add-QuickPackageToProfile
        Mock Add-QuickUtility

        Install-QuickPackage -Uninstall
        Assert-MockCalled Remove-QuickPackage -Times 1
    }

    It "Uninstall QuickPackageUtility if Uninstall flag is called" {
        Invoke-Expression (Get-MockImportsHeader)
        Mock Remove-QuickUtilityBelt
        Mock Remove-QuickPackage
        Mock Add-QuickPackage
        Mock Add-QuickPackageToProfile
        Mock Add-QuickUtility

        Install-QuickPackage -Uninstall
        Assert-MockCalled Remove-QuickUtilityBelt -Times 1
    }

    It "Does not install anything if Uninstall flag is called" {
        Invoke-Expression (Get-MockImportsHeader)
        Mock Remove-QuickUtilityBelt
        Mock Remove-QuickPackage
        Mock Add-QuickPackage
        Mock Add-QuickPackageToProfile
        Mock Add-QuickUtility

        Install-QuickPackage -Uninstall
        Assert-MockCalled Add-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackageToProfile -Times 0
        Assert-MockCalled Add-QuickUtility -Times 0
    }

    It "Successfully imports all files" {
        Invoke-Expression (Get-TestImportsHeader)

        # Should throw AssertionError if any Imports are missing
        Install-QuickPackage

        Assert-MockCalled Test-ImportCompleted -Times 1
    }
}

