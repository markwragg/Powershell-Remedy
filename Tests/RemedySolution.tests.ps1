BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

Describe 'Get-RemedySolution' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedySolution-InvokeRestMethod.xml }
    }

    It 'Should Throw if no search criteria is provided' {
        { Get-RemedySolution } | Should -Throw
    }

    It 'Should return if <_> is provided' -ForEach 'ID', 'Team', 'Customer', 'Assignee', 'Submitter' {
        $Param = @{ $_ = 'SomeValue' }

        { Get-RemedySolution @Param } | Should -Not -Throw
        Get-RemedySolution @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Status = <_> is provided' -ForEach 'AllOpen', 'AllClosed', 'Inactive', 'Active' {
        $Param = @{ Status = $_ }

        { Get-RemedySolution @Param } | Should -Not -Throw
        Get-RemedySolution @Param | Should -Not -BeNullOrEmpty
    }

    $TypeCases = foreach ($PropertyName in 'Type', 'ExcludeType') {
        foreach ($Value in 'Incident', 'Change', 'Problem Investigation', 'Known Error', 'Solution', 'Task',
            'CI Unavailability', 'Purchase Requisition', 'Release', 'Activity') {
            @{ PropertyName = $PropertyName; Value = $Value }
        }
    }

    It 'Should return if <PropertyName> = <Value> is provided' -ForEach $TypeCases {
        $Param = @{ $PropertyName = $Value }

        { Get-RemedySolution @Param } | Should -Not -Throw
        Get-RemedySolution @Param | Should -Not -BeNullOrEmpty
    }

    It 'Should return if Priority = <_> is provided' -ForEach 'Low', 'Medium', 'High', 'Critical' {
        $Param = @{ Priority = $_ }

        { Get-RemedySolution @Param } | Should -Not -Throw
        Get-RemedySolution @Param | Should -Not -BeNullOrEmpty
    }

    Context 'Valid Solution' {

        It 'Should not Throw for a valid Solution' {
            { Get-RemedySolution -ID 'ValidID' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Solution' {
            Get-RemedySolution -ID 'ValidID' | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Valid Solution with -Full details' {

        It 'Should not Throw for a valid Solution' {
            { Get-RemedySolution -ID 'ValidID' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid Solution' {
            Get-RemedySolution -ID 'ValidID' -Full | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Invalid Solution' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should be Null or Empty for an invalid Solution' {
            Get-RemedySolution -ID 'InvalidID' | Should -BeNullOrEmpty
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
