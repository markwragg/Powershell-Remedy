$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }

Describe 'Get-RemedyKnownError' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyKnownError-InvokeRestMethod.xml }

    It 'Should Throw if no search criteria is provided' {
        {Get-RemedyKnownError} | Should Throw
    }
    
    'ID','Team','Customer','Assignee','Submitter' | ForEach-Object {
        
        $Param = @{$_ = 'SomeValue'}
    
        It "Should return if $_ is provided" {
            {Get-RemedyKnownError @Param} | Should Not Throw
            Get-RemedyKnownError @Param | Should Not Be NullOrEmpty
        }
    }

    'AllOpen','AllClosed','Assigned','Scheduled For Correction','Assigned To Vendor',
    'No Action Planned','Corrected','Closed','Cancelled' | ForEach-Object {
        
        $Param = @{Status = $_}
    
        It "Should return if Status = $_ is provided" {
            {Get-RemedyKnownError @Param} | Should Not Throw
            Get-RemedyKnownError @Param | Should Not Be NullOrEmpty
        }
    }
    
    'Type','ExcludeType' | ForEach-Object {
        $PropertyName = $_

        'Incident','Change','Problem Investigation','Known Error','Knowledge','Task',
        'CI Unavailability','Purchase Requisition','Release','Activity' | ForEach-Object {
        
            $Param = @{$PropertyName = $_}
    
            It "Should return if $PropertyName = $_ is provided" {
                {Get-RemedyKnownError @Param} | Should Not Throw
                Get-RemedyKnownError @Param | Should Not Be NullOrEmpty
            }
        }
    }

    'Low','Medium','High','Critical' | ForEach-Object {
        
        $Param = @{Priority = $_}
    
        It "Should return if Priority = $_ is provided" {
            {Get-RemedyKnownError @Param} | Should Not Throw
            Get-RemedyKnownError @Param | Should Not Be NullOrEmpty
        }
    }

    Context 'Valid Known Error' {

        It 'Should not Throw for a valid Known Error' {
            {Get-RemedyKnownError -ID 'ValidID'} | Should Not Throw
        }
    
        $SomeKnownError = Get-RemedyKnownError -ID 'ValidID'

        It 'Should Not be Null or Empty for a valid Known Error' {
            $SomeKnownError | Should Not BeNullOrEmpty
        }
    }

    Context 'Valid Known Error with -Full details' {

        It 'Should not Throw for a valid Known Error' {
            {Get-RemedyKnownError -ID 'ValidID' -Full} | Should Not Throw
        }
    
        $SomeKnownErrorFull = Get-RemedyKnownError -ID 'ValidID' -Full
       
        It 'Should Not be Null or Empty for a valid Known Error' {
            $SomeKnownErrorFull | Should Not BeNullOrEmpty
        }

    }

    Mock Invoke-RestMethod  -Verifiable { }
    
    Context 'Invalid KnownError' {

        It 'Should be Null or Empty for an invalid Known Error' {
            Get-RemedyKnownError -ID 'InvalidID' | Should Be $null
        }
    }

    Assert-VerifiableMocks
}