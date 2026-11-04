BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}


Describe 'Set-RemedyApiConfig' -Tag Unit {

    BeforeAll {
        $TestPath = 'TestDrive:\SetRemedyApiConfig.xml'
        $ExportClixml = Get-Command Export-Clixml

        Mock Export-Clixml -Verifiable {
            $InputObject | & $ExportClixml -Path $TestPath
        }

        Mock Get-Credential -Verifiable {
            $secpasswd = ConvertTo-SecureString 'testpassword' -AsPlainText -Force
            New-Object System.Management.Automation.PSCredential ('testuser', $secpasswd)
        }
    }

    It 'Should not Throw' {
        { Set-RemedyApiConfig -APIURL 'https://mock.setconfig.com/arapi/midservername' -IncidentURL 'https://mock.setconfig.com/arsys/forms/helpdesk' } | Should -Not -Throw
    }

    It 'Should create the config file' {
        $TestPath | Should -Exist
    }

    It 'Should set an APIURL String' {
        $SetConfig = Import-Clixml $TestPath
        $SetConfig.APIURL | Should -BeOfType [string]
        $SetConfig.APIURL | Should -Be 'https://mock.setconfig.com/arapi/midservername'
    }

    It 'Should set an IncidentURL String' {
        $SetConfig = Import-Clixml $TestPath
        $SetConfig.IncidentURL | Should -BeOfType [string]
        $SetConfig.IncidentURL | Should -Be 'https://mock.setconfig.com/arsys/forms/helpdesk'
    }

    It 'Should set a Credentials SecureString' {
        $SetConfig = Import-Clixml $TestPath
        $SetConfig.Credentials | Should -BeOfType [securestring]
        { $SetConfig.Credentials | ConvertFrom-SecureString } | Should -Not -Throw
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}


Describe 'Get-RemedyApiConfig' -Tag Unit {

    Context 'Valid config' {

        BeforeAll {
            $ImportClixml = Get-Command Import-Clixml

            Mock Import-Clixml -Verifiable {
                & $ImportClixml -Path $here\Mock-GetRemedyApiConfig.xml
            }

            Mock Decrypt -Verifiable {
                'dGVzdHVzZXI6dGVzdHBhc3N3b3Jk'
            }
        }

        It 'Should not Throw' {
            { Get-RemedyApiConfig } | Should -Not -Throw
        }

        It 'Should return config data' {
            Get-RemedyApiConfig | Should -Not -BeNullOrEmpty
        }

        It 'Should return an APIURL property' {
            $GetConfig = Get-RemedyApiConfig
            $GetConfig.APIURL | Should -BeOfType [string]
            $GetConfig.APIURL | Should -Be 'https://mock.server.com/arapi/midservername'
        }

        It 'Should return an IncidentURL property' {
            $GetConfig = Get-RemedyApiConfig
            $GetConfig.IncidentURL | Should -BeOfType [string]
            $GetConfig.IncidentURL | Should -Be 'https://mock.server.com/arsys/forms/helpdesk'
        }

        It 'Should return a Credentials property' {
            $GetConfig = Get-RemedyApiConfig
            $GetConfig.Credentials | Should -BeOfType [string]
            $GetConfig.Credentials | Should -Be 'dGVzdHVzZXI6dGVzdHBhc3N3b3Jk'
        }

        It 'Should have invoked all verifiable mocks' {
            Should -InvokeVerifiable
        }
    }

    Context 'Invalid config' {

        BeforeAll {
            Mock Import-Clixml -Verifiable { throw }
        }

        It 'Should Throw' {
            { Get-RemedyApiConfig } | Should -Throw -ExpectedMessage 'Remedy API config not set. Use Set-RemedyApiConfig first.'
        }

        It 'Should have invoked all verifiable mocks' {
            Should -InvokeVerifiable
        }
    }
}


Describe 'Update-RemedyApiConfig' -Tag Unit {

    BeforeAll {
        $TestPath = 'TestDrive:\UpdateRemedyApiConfig.xml'
        $ExportClixml = Get-Command Export-Clixml

        Mock Get-RemedyApiConfig -Verifiable {
            Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
        }

        Mock Export-Clixml -Verifiable {
            $InputObject | & $ExportClixml -Path $TestPath
        }

        Mock Get-Credential -Verifiable {
            $secpasswd = ConvertTo-SecureString 'testpassword' -AsPlainText -Force
            New-Object System.Management.Automation.PSCredential ('testuser', $secpasswd)
        }
    }

    It 'Should not Throw' {
        { Update-RemedyApiConfig } | Should -Not -Throw
    }

    It 'Should create the config file' {
        $TestPath | Should -Exist
    }

    It 'Should update an APIURL String' {
        $UpdateConfig = Import-Clixml $TestPath
        $UpdateConfig.APIURL | Should -BeOfType [string]
        $UpdateConfig.APIURL | Should -Be 'https://mock.server.com/arapi/midservername'
    }

    It 'Should update an IncidentURL String' {
        $UpdateConfig = Import-Clixml $TestPath
        $UpdateConfig.IncidentURL | Should -BeOfType [string]
        $UpdateConfig.IncidentURL | Should -Be 'https://mock.server.com/arsys/forms/helpdesk'
    }

    It 'Should update a Credentials SecureString' {
        $UpdateConfig = Import-Clixml $TestPath
        $UpdateConfig.Credentials | Should -BeOfType [securestring]
        { $UpdateConfig.Credentials | ConvertFrom-SecureString } | Should -Not -Throw
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}


Describe 'Test-RemedyApiConfig' -Tag Unit {

    Context 'Successful API Response' {

        BeforeAll {
            $ImportClixml = Get-Command Import-Clixml

            Mock Get-RemedyApiConfig -Verifiable {
                Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
            }
            Mock Invoke-WebRequest -Verifiable {
                & $ImportClixml -Path $here\Mock-TestRemedyApiConfig-InvokeWebRequest.xml
            }

            Mock Update-RemedyApiConfig { }
        }

        It 'Should not Throw' {
            { Test-RemedyApiConfig } | Should -Not -Throw
        }

        It 'Should return True' {
            Test-RemedyApiConfig | Should -Be $true
        }

        It 'Should have invoked all verifiable mocks' {
            Should -InvokeVerifiable
        }
    }

    Context 'Authentication Failure API Response' {

        BeforeAll {
            $Script:UpdateConfigCount = 0

            Mock Get-RemedyApiConfig -Verifiable {
                Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
            }
            Mock Invoke-WebRequest -Verifiable {
                $Result = if ($Script:UpdateConfigCount -lt 3) { "$here\Mock-TestRemedyApiConfig-InvokeWebRequest-AuthFail.xml" } else { "$here\Mock-TestRemedyApiConfig-InvokeWebRequest.xml" }
                Import-Clixml -Path $Result
            }

            Mock Update-RemedyApiConfig -Verifiable { $Script:UpdateConfigCount++ }
        }

        It 'Should retry via Update-RemedyApiConfig and return True once authentication succeeds' {
            Test-RemedyApiConfig | Should -Be $true
            Should -Invoke -CommandName 'Update-RemedyApiConfig' -Times 3 -Exactly
        }
    }

    Context 'Bad URL API Response' {

        BeforeAll {
            Mock Get-RemedyApiConfig -Verifiable {
                Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
            }

            Mock Update-RemedyApiConfig { }

            Mock Invoke-WebRequest -Verifiable { Import-Clixml -Path "$here\Mock-TestRemedyApiConfig-InvokeWebRequest-BadResponse.xml" }
        }

        It 'Should return False for a bad URL' {
            Test-RemedyApiConfig | Should -Be $false
        }

        It 'Should have invoked all verifiable mocks' {
            Should -InvokeVerifiable
        }
    }
}
