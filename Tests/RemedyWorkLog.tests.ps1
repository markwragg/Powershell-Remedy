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

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Title', 'Note', 'Submitter', 'WorkLogType' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedyWorkLog @Param } | Should -Not -Throw
        Get-RemedyWorkLog @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -Exact is provided' {
        { Get-RemedyWorkLog -ID 'ValidID' -Exact } | Should -Not -Throw
        Get-RemedyWorkLog -ID 'ValidID' -Exact | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -After and -Before are provided' {
        $Param = @{ Team = 'SomeValue'; After = (Get-Date).AddMonths(-1); Before = (Get-Date) }

        { Get-RemedyWorkLog @Param } | Should -Not -Throw
        Get-RemedyWorkLog @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Type = <_> is provided' -ForEach 'Change', 'Problem', 'KnownError', 'Solution' {
        $Param = @{ ID = 'SomeValue'; Type = $_ }

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

    Context 'Failed API config test' {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { $false }
        }

        It 'Should Throw' {
            { Get-RemedyWorkLog -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'API connectivity error' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { throw 'Some error' }
        }

        It 'Should write a non-terminating error without throwing' {
            { Get-RemedyWorkLog -ID 'ValidID' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
