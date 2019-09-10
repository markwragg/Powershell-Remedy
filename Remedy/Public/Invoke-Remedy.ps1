﻿Function Invoke-Remedy {
<#
.SYNOPSIS
    Opens a Remedy Incident URL in your default web browser.

.DESCRIPTION
    This function can be used to open one or more Remedy Incidents in your browser. It accepts input from the pipeline
    so can be used in conjunction with Get-RemedyTicket. You can also input a comma-separated list of Incident IDs either
    by just number or via the full ID string (or a combination).
    
    By default this function will prompt if you want to continue every 5 URLs it opens. If you want to disable this prompt
    use -Force.

.EXAMPLE
    Invoke-Remedy -ID INC000002264704

    Open the specified incident.
.EXAMPLE
    2160742,2264704 | Invoke-Remedy

    Open the specified incidents.
.EXAMPLE
    Get-RemedyTicket -ID 2160742 | Invoke-Remedy

    Open the specified ticket.
#>
    [cmdletbinding(DefaultParameterSetName='ByID',SupportsShouldProcess)]
    Param (
        #The ID number of the Incident you wish to open.
        [parameter(Position=0,Mandatory,ParameterSetName=’ByID’,ValueFromPipeline)]
        [String[]]$ID,

        #Used to accept input of small numbers.
        [parameter(ParameterSetName=’ByID’,ValueFromPipeline,DontShow)]
        [Int[]]$Number,

        #Used to accept input of large numbers.
        [parameter(ParameterSetName=’ByID’,ValueFromPipeline,DontShow)]
        [Int64[]]$LongNumber,

        #Used to accept input by ticket object (as generated by Get-RemedyTicket).
        [parameter(ParameterSetName=’ByObject’,ValueFromPipeline)]
        [Object[]]$InputObject,

        #Use -Force to override the continue check that will occur if more than 5 URLs are being opened.
        [Switch]$Force
    )  
    Begin{
        $IncidentURL = (Get-RemedyApiConfig).IncidentURL
        If (-not $IncidentURL) { Throw 'Could not get Remedy Incident URL. Please Use Set-RemedyApiConfig first' }
        
        $Script:InvokeRemedyCounter = 0
    }
    Process{  
        If ($InputObject){
            If ($InputObject.'Incident Number') { 
                $ID = $InputObject.'Incident Number' 
            } Else { 
                Throw "Input object did not have an 'Incident Number' property" 
            }
        }
        
        If ($ID){
            $ID | ForEach-Object {
                If ( ($_ -as [int64]) -and ($_.Length -le 12) ) { $_ = "INC$('0'*(12-$_.Length))$_" }
                If ($PSCmdlet.ShouldProcess($_)) {  
                    Start-Process "$IncidentURL/?qual=%271000000161%27=%22$_%22"

                    $Script:InvokeRemedyCounter++
                    If ($Script:InvokeRemedyCounter % 5 -eq 0 -and -not $Force) { 
                        If ((Read-Host '5 URLs opened. Continue? y/n (use -Force to override this check)') -eq 'n') { 
                            Throw 'Stopped by user choice.' 
                        }
                    }
                }
            }
        }
    }
    End {
        $Script:InvokeRemedyCounter = $null
    }
}