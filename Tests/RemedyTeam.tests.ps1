$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }


Describe 'Get-RemedyTeam' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    Mock Test-RemedyApiConfig -Verifiable { $True }
    Mock Get-RemedyInterface -Verifiable { @{'Support Group ID' = 'SGP000000001234'} }
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyTeam-InvokeRestMethod.xml }

    Context 'Valid team' {

        It 'Should not Throw for a valid team' {
            {Get-RemedyTeam -Name 'Reporters'} | Should Not Throw
        }
    
        $SomeTeam = Get-RemedyTeam -name 'Reporters'

        It 'Should Not be Null or Empty for a valid team' {
            $SomeTeam | Should Not BeNullOrEmpty
        }

        'Clark Kent','Lois Lane' | ForEach-Object {
            It "Should return $_" {
                $_ -in $SomeTeam.'Full Name' | Should Be True
            }
        }

        'Full Name','Login ID' | ForEach-Object {
            It "Should return a $_ property" {
                $SomeTeam.$_ | Should Not Be $null
            }
        }
    }


    Context 'Valid team with -Full details' {

        It 'Should not Throw for a valid team' {
            {Get-RemedyTeam -Name 'Reporters' -Full} | Should Not Throw
        }
    
        $SomeTeamFull = Get-RemedyTeam -name 'Reporters' -Full
       
        It 'Should Not be Null or Empty for a valid team' {
            $SomeTeamFull | Should Not BeNullOrEmpty
        }

        'Clark Kent','Lois Lane' | ForEach-Object {
            It "Should return $_" {
                $_ -in $SomeTeamFull.'Full Name' | Should Be True
            }
        }

        'Full Name','Login ID','Status','Submit Date' | ForEach-Object {
            It "Should return a $_ property" {
                $SomeTeamFull.$_ | Should Not Be $null
            }
        }
    }

    Mock Get-RemedyInterface  -Verifiable { }
    
    Context 'Invalid Team' {

        It 'Should Throw for an invalid team' {
            {Get-RemedyTeam -Name 'SuperVillians'} | Should Throw
        }
    }
    
    Assert-VerifiableMocks
}