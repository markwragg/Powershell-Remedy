$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }

Describe 'Get-RemedyProblem' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyProblem-InvokeRestMethod.xml }

    It 'Should Throw if no search criteria is provided' {
        {Get-RemedyProblem} | Should Throw
    }
    
    'ID','Team','Customer','Assignee','Submitter' | ForEach-Object {
        
        $Param = @{$_ = 'SomeValue'}
    
        It "Should return if $_ is provided" {
            {Get-RemedyProblem @Param} | Should Not Throw
            Get-RemedyProblem @Param | Should Not Be NullOrEmpty
        }
    }

    'AllOpen','AllClosed','Draft','Under Review','Request For Authorization','Assigned','Under Investigation',
    'Pending','Rejected','Completed','Closed','Cancelled' | ForEach-Object {
        
        $Param = @{Status = $_}
    
        It "Should return if Status = $_ is provided" {
            {Get-RemedyProblem @Param} | Should Not Throw
            Get-RemedyProblem @Param | Should Not Be NullOrEmpty
        }
    }
    
    'Type','ExcludeType' | ForEach-Object {
        $PropertyName = $_

        'Incident','Change','Problem Investigation','Known Error','Knowledge','Task',
        'CI Unavailability','Purchase Requisition','Release','Activity' | ForEach-Object {
        
            $Param = @{$PropertyName = $_}
    
            It "Should return if $PropertyName = $_ is provided" {
                {Get-RemedyProblem @Param} | Should Not Throw
                Get-RemedyProblem @Param | Should Not Be NullOrEmpty
            }
        }
    }

    'Low','Medium','High','Critical' | ForEach-Object {
        
        $Param = @{Priority = $_}
    
        It "Should return if Priority = $_ is provided" {
            {Get-RemedyProblem @Param} | Should Not Throw
            Get-RemedyProblem @Param | Should Not Be NullOrEmpty
        }
    }

    Context 'Valid Problem' {

        It 'Should not Throw for a valid Problem' {
            {Get-RemedyProblem -ID 'ValidID'} | Should Not Throw
        }
    
        $SomeProblem = Get-RemedyProblem -ID 'ValidID'

        It 'Should Not be Null or Empty for a valid Problem' {
            $SomeProblem | Should Not BeNullOrEmpty
        }
    }

    Context 'Valid Problem with -Full details' {

        It 'Should not Throw for a valid Problem' {
            {Get-RemedyProblem -ID 'ValidID' -Full} | Should Not Throw
        }
    
        $SomeProblemFull = Get-RemedyProblem -ID 'ValidID' -Full
       
        It 'Should Not be Null or Empty for a valid Problem' {
            $SomeProblemFull | Should Not BeNullOrEmpty
        }

    }

    Mock Invoke-RestMethod  -Verifiable { }
    
    Context 'Invalid Problem' {

        It 'Should be Null or Empty for an invalid Problem' {
            Get-RemedyProblem -ID 'InvalidID' | Should Be $null
        }
    }

    Assert-VerifiableMock
}