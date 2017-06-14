Function Test-RemedyApiConfig {
<#
.SYNOPSIS
    Tests credentials and URL for use with the Remedy API.
#>
    [cmdletbinding()]
    [OutputType([Boolean])]
    Param(
        $Path = "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml"
    )
    
    Try {
        $Config = Get-RemedyApiConfig -Path $Path
        
        Try {

            $Headers = @{ Authorization = "Basic $($Config.Credentials)" }
            $Result = Invoke-WebRequest -URI "$($Config.APIURL)/Home Page" -Headers $Headers

            Write-Verbose "$($Result.Content)"

            If ($Result.Content -like 'ARException: ERROR (623): Authentication failed;*'){ 
                Update-RemedyApiConfig
                Test-RemedyApiConfig
                Break
            }

            Try {
                $ResultObj = ConvertFrom-Json $Result.Content -ErrorAction Stop
                $validJson = $true
            } Catch {
                $validJson = $false
                Write-Verbose 'Result was not JSON'
            }

            If ($validJson -and $Result.Content -notlike 'ARException: ERROR*'){ $True } Else { $False } 
            
        } Catch {
            $False
            Write-Verbose $_
        }

    } Catch {
        $False
        Write-Verbose "Remedy API config not set. Use Set-RemedyApiConfig first."
    }
}