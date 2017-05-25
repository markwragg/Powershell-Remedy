Function Get-RemedyApiConfig {
<#
.SYNOPSIS
    Get credentials and URL for use with the Remedy API.
#>
    Param(
        $Path = "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml"
    )
    
    Function Decrypt ($String) {
        If($String -is [System.Security.SecureString]) {
            [System.Runtime.InteropServices.marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.marshal]::SecureStringToBSTR(
                    $string))
        }
    }
        
    $Config = (Import-Clixml -Path $Path)
    $Config.Credentials = Decrypt $Config.Credentials

    Write-Output $Config
}