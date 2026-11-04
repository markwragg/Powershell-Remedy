BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}


Describe 'Get-RemedyTicket' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyTicket-InvokeRestMethod.xml }
    }

    It 'Should Throw if no search criteria is provided' {
        { Get-RemedyTicket } | Should -Throw
    }

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Customer', 'ConfigurationItem', 'Assignee', 'Submitter' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -Exact is provided' {
        { Get-RemedyTicket -ID 'ValidID' -Exact } | Should -Not -Throw
        Get-RemedyTicket -ID 'ValidID' -Exact | Should -Not -BeNullOrEmpty
    }

    It 'Should return if -After and -Before are provided' {
        $Param = @{ Team = 'SomeValue'; After = (Get-Date).AddMonths(-1); Before = (Get-Date) }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Type = <_> is provided' -ForEach 'User Service Restoration', 'User Service Request', 'Service Improvement' {
        $Param = @{ ID = 'ValidID'; Type = $_ }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if ExcludeType = <_> is provided' -ForEach 'User Service Restoration', 'User Service Request', 'Service Improvement' {
        $Param = @{ ID = 'ValidID'; ExcludeType = $_ }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Status = <_> is provided' -ForEach 'AllOpen', 'AllClosed', 'New', 'Assigned', 'In Progress', 'Pending', 'Closed', 'Resolved' {
        $Param = @{ Status = $_ }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    $SourceCases = foreach ($PropertyName in 'Source', 'ExcludeSource') {
        foreach ($Value in 'Email', 'Automation', 'Phone', 'Self Service (Portal)', 'Event Management', 'Chat', 'Instant Message', 'E-Bonding') {
            @{ PropertyName = $PropertyName; Value = $Value }
        }
    }

    It 'Should return if <PropertyName> = <Value> is provided' -ForEach $SourceCases {
        $Param = @{ $PropertyName = $Value }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Priority = <_> is provided' -ForEach 'Low', 'Medium', 'High', 'Critical' {
        $Param = @{ Priority = $_ }

        { Get-RemedyTicket @Param } | Should -Not -Throw
        Get-RemedyTicket @Param | Should -Not -BeNullOrEmpty
    }

    Context 'Valid ticket' {

        It 'Should not Throw for a valid ticket' {
            { Get-RemedyTicket -ID 'ValidID' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid ticket' {
            Get-RemedyTicket -ID 'ValidID' | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Valid ticket with -Full details' {

        It 'Should not Throw for a valid ticket' {
            { Get-RemedyTicket -ID 'ValidID' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid ticket' {
            Get-RemedyTicket -ID 'ValidID' -Full | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Invalid Ticket' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should be Null or Empty for an invalid ticket' {
            Get-RemedyTicket -ID 'InvalidID' | Should -BeNullOrEmpty
        }
    }

    Context 'Missing API configuration' {

        BeforeAll {
            Mock Get-RemedyApiConfig -Verifiable { @{ Credentials = ''; APIURL = '' } }
        }

        It 'Should Throw' {
            { Get-RemedyTicket -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Config not set. Set-RemedyApiConfig first.'
        }
    }

    Context 'Failed API config test' {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { $false }
        }

        It 'Should Throw' {
            { Get-RemedyTicket -ID 'ValidID' } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'API connectivity error' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { throw 'Some error' }
        }

        It 'Should write a non-terminating error without throwing' {
            { Get-RemedyTicket -ID 'ValidID' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
