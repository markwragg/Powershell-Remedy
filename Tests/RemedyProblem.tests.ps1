BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

Describe 'Get-RemedyProblem' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyProblem-InvokeRestMethod.xml }
    }

    It 'Should Throw if no search criteria is provided' {
        { Get-RemedyProblem } | Should -Throw
    }

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Customer', 'ConfigurationItem', 'Assignee', 'Submitter' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedyProblem @Param } | Should -Not -Throw
        Get-RemedyProblem @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -Exact is provided' {
        { Get-RemedyProblem -ID 'ValidID' -Exact } | Should -Not -Throw
        Get-RemedyProblem -ID 'ValidID' -Exact | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -After and -Before are provided' {
        $Param = @{ Team = 'SomeValue'; After = (Get-Date).AddMonths(-1); Before = (Get-Date) }

        { Get-RemedyProblem @Param } | Should -Not -Throw
        Get-RemedyProblem @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Status = <_> is provided' -ForEach 'AllOpen', 'AllClosed', 'Draft', 'Under Review', 'Request For Authorization', 'Assigned', 'Under Investigation',
    'Pending', 'Rejected', 'Completed', 'Closed', 'Cancelled' {
        $Param = @{ Status = $_ }

        { Get-RemedyProblem @Param } | Should -Not -Throw
        Get-RemedyProblem @Param | Should -Not -BeNullOrEmpty
    }

    $TypeCases = foreach ($PropertyName in 'Type', 'ExcludeType') {
        foreach ($Value in 'Incident', 'Change', 'Problem Investigation', 'Known Error', 'Knowledge', 'Task',
            'CI Unavailability', 'Purchase Requisition', 'Release', 'Activity') {
            @{ PropertyName = $PropertyName; Value = $Value }
        }
    }

    It 'Should return if <PropertyName> = <Value> is provided' -ForEach $TypeCases {
        $Param = @{ $PropertyName = $Value }

        { Get-RemedyProblem @Param } | Should -Not -Throw
        Get-RemedyProblem @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Priority = <_> is provided' -ForEach 'Low', 'Medium', 'High', 'Critical' {
        $Param = @{ Priority = $_ }

        { Get-RemedyProblem @Param } | Should -Not -Throw
        Get-RemedyProblem @Param | Should -Not -BeNullOrEmpty
    }

    Context 'Valid Problem' {

        It 'Should not Throw for a valid Problem' {
            { Get-RemedyProblem -ID 'ValidID' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Problem' {
            Get-RemedyProblem -ID 'ValidID' | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Valid Problem with -Full details' {

        It 'Should not Throw for a valid Problem' {
            { Get-RemedyProblem -ID 'ValidID' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Problem' {
            Get-RemedyProblem -ID 'ValidID' -Full | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Invalid Problem' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should be Null or Empty for an invalid Problem' {
            Get-RemedyProblem -ID 'InvalidID' | Should -BeNullOrEmpty
        }
    }

    Context 'Missing API configuration' {

        BeforeAll {
            Mock Get-RemedyApiConfig -Verifiable { @{ Credentials = ''; APIURL = '' } }
        }

        It 'Should Throw' {
            { Get-RemedyProblem -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Config not set. Set-RemedyApiConfig first.'
        }
    }

    Context 'Failed API config test' {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { $false }
        }

        It 'Should Throw' {
            { Get-RemedyProblem -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'API connectivity error' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { throw 'Some error' }
        }

        It 'Should write a non-terminating error without throwing' {
            { Get-RemedyProblem -ID 'ValidID' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
