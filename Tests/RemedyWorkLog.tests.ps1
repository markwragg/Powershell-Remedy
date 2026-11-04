BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}


Describe 'Get-RemedyWorkLog' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml $here\Mock-GetRemedyWorkLog-InvokeRestMethod.xml }
    }

    It 'Should Throw if no search criteria is provided' {
        { Get-RemedyWorkLog } | Should -Throw
    }

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Title', 'Note', 'Submitter' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedyWorkLog @Param } | Should -Not -Throw
        Get-RemedyWorkLog @Param | Should -Not -BeNullOrEmpty
    }

    Context 'Valid worklog' {

        It 'Should not Throw for a valid worklog' {
            { Get-RemedyWorkLog -ID 'ValidID' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid worklog' {
            Get-RemedyWorkLog -ID 'ValidID' | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Valid worklog with -Full details' {

        It 'Should not Throw for a valid worklog' {
            { Get-RemedyWorkLog -ID 'ValidID' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid worklog' {
            Get-RemedyWorkLog -ID 'ValidID' -Full | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Invalid worklog' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should be Null or Empty for an invalid worklog' {
            Get-RemedyWorkLog -ID 'InvalidID' | Should -BeNullOrEmpty
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
