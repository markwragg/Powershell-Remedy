BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

Describe 'Get-RemedyKnownError' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyKnownError-InvokeRestMethod.xml }
    }

    It 'Should Throw if no search criteria is provided' {
        { Get-RemedyKnownError } | Should -Throw
    }

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Customer', 'Assignee', 'Submitter' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedyKnownError @Param } | Should -Not -Throw
        Get-RemedyKnownError @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Status = <_> is provided' -ForEach 'AllOpen', 'AllClosed', 'Assigned', 'Scheduled For Correction', 'Assigned To Vendor',
    'No Action Planned', 'Corrected', 'Closed', 'Cancelled' {
        $Param = @{ Status = $_ }

        { Get-RemedyKnownError @Param } | Should -Not -Throw
        Get-RemedyKnownError @Param | Should -Not -BeNullOrEmpty
    }

    $TypeCases = foreach ($PropertyName in 'Type', 'ExcludeType') {
        foreach ($Value in 'Incident', 'Change', 'Problem Investigation', 'Known Error', 'Knowledge', 'Task',
            'CI Unavailability', 'Purchase Requisition', 'Release', 'Activity') {
            @{ PropertyName = $PropertyName; Value = $Value }
        }
    }

    It 'Should return if <PropertyName> = <Value> is provided' -ForEach $TypeCases {
        $Param = @{ $PropertyName = $Value }

        { Get-RemedyKnownError @Param } | Should -Not -Throw
        Get-RemedyKnownError @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Priority = <_> is provided' -ForEach 'Low', 'Medium', 'High', 'Critical' {
        $Param = @{ Priority = $_ }

        { Get-RemedyKnownError @Param } | Should -Not -Throw
        Get-RemedyKnownError @Param | Should -Not -BeNullOrEmpty
    }

    Context 'Valid Known Error' {

        It 'Should not Throw for a valid Known Error' {
            { Get-RemedyKnownError -ID 'ValidID' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Known Error' {
            Get-RemedyKnownError -ID 'ValidID' | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Valid Known Error with -Full details' {

        It 'Should not Throw for a valid Known Error' {
            { Get-RemedyKnownError -ID 'ValidID' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Known Error' {
            Get-RemedyKnownError -ID 'ValidID' -Full | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Invalid KnownError' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should be Null or Empty for an invalid Known Error' {
            Get-RemedyKnownError -ID 'InvalidID' | Should -BeNullOrEmpty
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
