$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }

Describe 'Get-RemedySolution' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedySolution-InvokeRestMethod.xml }

    It 'Should Throw if no search criteria is provided' {
        {Get-RemedySolution} | Should Throw
    }
    
    'ID','Team','Customer','Assignee','Submitter' | ForEach-Object {
        
        $Param = @{$_ = 'SomeValue'}
    
        It "Should return if $_ is provided" {
            {Get-RemedySolution @Param} | Should Not Throw
            Get-RemedySolution @Param | Should Not Be NullOrEmpty
        }
    }

    'AllOpen','AllClosed','Inactive','Active' | ForEach-Object {
        
        $Param = @{Status = $_}
    
        It "Should return if Status = $_ is provided" {
            {Get-RemedySolution @Param} | Should Not Throw
            Get-RemedySolution @Param | Should Not Be NullOrEmpty
        }
    }
    
    'Type','ExcludeType' | ForEach-Object {
        $PropertyName = $_

        'Incident','Change','Problem Investigation','Known Error','Solution','Task',
        'CI Unavailability','Purchase Requisition','Release','Activity' | ForEach-Object {
        
            $Param = @{$PropertyName = $_}
    
            It "Should return if $PropertyName = $_ is provided" {
                {Get-RemedySolution @Param} | Should Not Throw
                Get-RemedySolution @Param | Should Not Be NullOrEmpty
            }
        }
    }

    'Low','Medium','High','Critical' | ForEach-Object {
        
        $Param = @{Priority = $_}
    
        It "Should return if Priority = $_ is provided" {
            {Get-RemedySolution @Param} | Should Not Throw
            Get-RemedySolution @Param | Should Not Be NullOrEmpty
        }
    }

    Context 'Valid Solution' {

        It 'Should not Throw for a valid Solution' {
            {Get-RemedySolution -ID 'ValidID'} | Should Not Throw
        }
    
        $SomeSolution = Get-RemedySolution -ID 'ValidID'

        It 'Should Not be Null or Empty for a valid Solution' {
            $SomeSolution | Should Not BeNullOrEmpty
        }
    }

    Context 'Valid Solution with -Full details' {

        It 'Should not Throw for a valid Solution' {
            {Get-RemedySolution -ID 'ValidID' -Full} | Should Not Throw
        }
    
        $SomeSolutionFull = Get-RemedySolution -ID 'ValidID' -Full
       
        It 'Should Not be Null or Empty for a valid Solution' {
            $SomeSolutionFull | Should Not BeNullOrEmpty
        }

    }

    Mock Invoke-RestMethod  -Verifiable { }
    
    Context 'Invalid Solution' {

        It 'Should be Null or Empty for an invalid Solution' {
            Get-RemedySolution -ID 'InvalidID' | Should Be $null
        }
    }

    Assert-VerifiableMocks
}