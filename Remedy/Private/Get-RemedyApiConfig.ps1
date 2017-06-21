Function Decrypt ($String) {
    If($String -is [System.Security.SecureString]) {
        [System.Runtime.InteropServices.marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.marshal]::SecureStringToBSTR(
                $string))
    }
}

Function Get-RemedyApiConfig {
<#
.SYNOPSIS
    Get credentials and URL for use with the Remedy API.
#>
    Param(
        $Path = "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml"
    )
        
    Try {
        $Config = (Import-Clixml -Path $Path)
        $Config.Credentials = Decrypt $Config.Credentials

        $Config
    } Catch {
        Throw "Remedy API config not set. Use Set-RemedyApiConfig first."
    }
}