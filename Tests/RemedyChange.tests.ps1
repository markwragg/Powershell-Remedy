BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

Describe 'Get-RemedyChange' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyChange-InvokeRestMethod.xml }
    }

    It 'Should Throw if no search criteria is provided' {
        { Get-RemedyChange } | Should -Throw
    }

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Customer', 'ConfigurationItem', 'Assignee', 'Submitter' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedyChange @Param } | Should -Not -Throw
        Get-RemedyChange @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -Exact is provided' {
        { Get-RemedyChange -ID 'ValidID' -Exact } | Should -Not -Throw
        Get-RemedyChange -ID 'ValidID' -Exact | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -After and -Before are provided' {
        $Param = @{ Team = 'SomeValue'; After = (Get-Date).AddMonths(-1); Before = (Get-Date) }

        { Get-RemedyChange @Param } | Should -Not -Throw
        Get-RemedyChange @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Status = <_> is provided' -ForEach 'AllOpen', 'AllClosed', 'Draft', 'Request For Authorization', 'Request For Change', 'Planning In Progress', 'Scheduled For Review',
    'Scheduled For Approval', 'Scheduled', 'Implementation In Progress', 'Pending', 'Rejected', 'Completed', 'Closed', 'Cancelled' {
        $Param = @{ Status = $_ }

        { Get-RemedyChange @Param } | Should -Not -Throw
        Get-RemedyChange @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if ApprovalStatus = <_> is provided' -ForEach 'Pending', 'Approved', 'Rejected' {
        $Param = @{ ApprovalStatus = $_ }

        { Get-RemedyChange @Param } | Should -Not -Throw
        Get-RemedyChange @Param | Should -Not -BeNullOrEmpty
    }

    $TypeCases = foreach ($PropertyName in 'Type', 'ExcludeType') {
        foreach ($Value in 'Normal', 'Standard', 'Expedited', 'Emergency', 'Latent', 'No Impact') {
            @{ PropertyName = $PropertyName; Value = $Value }
        }
    }

    It 'Should return if <PropertyName> = <Value> is provided' -ForEach $TypeCases {
        $Param = @{ $PropertyName = $Value }

        { Get-RemedyChange @Param } | Should -Not -Throw
        Get-RemedyChange @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Priority = <_> is provided' -ForEach 'Low', 'Medium', 'High', 'Critical' {
        $Param = @{ Priority = $_ }

        { Get-RemedyChange @Param } | Should -Not -Throw
        Get-RemedyChange @Param | Should -Not -BeNullOrEmpty
    }

    Context 'Valid Change' {

        It 'Should not Throw for a valid Change' {
            { Get-RemedyChange -ID 'ValidID' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Change' {
            Get-RemedyChange -ID 'ValidID' | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Valid Change with -Full details' {

        It 'Should not Throw for a valid Change' {
            { Get-RemedyChange -ID 'ValidID' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Change' {
            Get-RemedyChange -ID 'ValidID' -Full | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Invalid Change' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should be Null or Empty for an invalid Change' {
            Get-RemedyChange -ID 'InvalidID' | Should -BeNullOrEmpty
        }
    }

    Context 'Missing API configuration' {

        BeforeAll {
            Mock Get-RemedyApiConfig -Verifiable { @{ Credentials = ''; APIURL = '' } }
        }

        It 'Should Throw' {
            { Get-RemedyChange -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Config not set. Set-RemedyApiConfig first.'
        }
    }

    Context 'Failed API config test' {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { $false }
        }

        It 'Should Throw' {
            { Get-RemedyChange -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'API connectivity error' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { throw 'Some error' }
        }

        It 'Should write a non-terminating error without throwing' {
            { Get-RemedyChange -ID 'ValidID' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
