﻿Function Get-RemedyWorkLog {
<#
.SYNOPSIS
    Retrieves BMC Remedy Work Log details via the API by ID number or other specified criteria such as Team, Submitter, Note, Title.

.DESCRIPTION
    This cmdlet queries the Remedy API for Incidents, Changes, Problems, Known Errors or Solutions as specified by ID number or by 
    combining one or more of the filter parameters.
    Beware that the Remedy API will return a maximum of 5000 records in a single request. If you need to exceed this, make multiple
    requests (e.g by separating by date range) and then combine the results.

.EXAMPLE
    Get-RemedyWorkLog -ID 123456

    Returns the specified Work Log.

.EXAMPLE
    Get-RemedyWorkLog -Team Windows -After 01/15/2016 -Before 02/15/2016

    Returns Work Logs for the specified team between the specified dates.

.EXAMPLE
    Get-RemedyChange 1234 | Get-RemedyWorkLog

    Return the work logs for the specified change.

.EXAMPLE
    Get-RemedyProblem 2345 | Get-RemedyWorkLog

    Returns the work logs for the specified problem.

.EXAMPLE
    Get-RemedyKnownError 3456 | Get-RemedyWorkLog

    Return the work logs for the specified known error.


.EXAMPLE
    Get-RemedySolution 4567 | Get-RemedyWorkLog

    Return the work log for the specified solution.
#>
    [cmdletbinding()]
    Param(
        # One or more Incident ID numbers.
        [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
        [Alias('Incident Number','Infrastructure Change ID','Problem Investigation ID','Known Error ID','Solution Database ID')]
        [String[]]$ID = '',
        
        # Work log entries created by the specified team. This must be an exact match.
        [String]$Team,
        
        # Work log entries with specific text in the work note title.
        [String]$Title,
        
        # Work log entries with specific text in the work note text.
        [String]$Note,
        
        # Work log entries submitted by the specified individual.
        [String]$Submitter,

        # Work log entries with a 'submit date' that is after this date. Use US date format: mm/dd/yyyy
        [DateTime]$After,
        
        # Work log entries with a 'submit date' that is before this date. Use US date format: mm/dd/yyyy
        [DateTime]$Before,

        # Work log entried of a specific type, e.g 'General Information','Internal Update','MOP' etc. This must be an exact match.
        [String]$WorkLogType,
        
        # Specify the type of WorkLog to retrieve: Incident, Change, Problem, KnownError, Solution. This is only necessary when providing a partial ID number.
        [ValidateSet('Incident','Change','Problem','KnownError','Solution')]
        [String]$Type,

        # Return all available data fields from Remedy.
        [Switch]$Full,

        # Perform an exact match for any text filter provided.
        [Switch]$Exact,
                
        # An encoded string representing your Remedy Credentials as generated by the Set-RemedyApiConfig cmdlet.
        [String]$EncodedCredentials = (Get-RemedyApiConfig).Credentials,
        
        # The Remedy API URL. E.g: https://<localhost>:<port>/api
        [String]$APIURL = (Get-RemedyApiConfig).APIURL
    )
    Begin {
        If (-not (Test-RemedyApiConfig)) { Throw 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.' }
    }
    Process {

        ForEach ($IDNum in $ID) {
            Write-Verbose "$IDNum"
            
            Switch ($IDNum) {
                {$_ -like 'CRQ*' -or $Type -eq 'Change'} {
                    $Interface = 'CHG:WorkLog' 
                    $IDText = 'Infrastructure Change ID'
                }
                {$_ -like 'PBI*' -or $Type -eq 'Problem'} {
                    $Interface = 'PBM:Investigation WorkLog' 
                    $IDText = 'Problem Investigation ID'
                }
                {$_ -like 'PKE*' -or $Type -eq 'KnownError'} {
                    $Interface = 'PBM:Known Error WorkLog' 
                    $IDText = 'Known Error ID'
                }
                {$_ -like 'SDB*' -or $Type -eq 'Solution'} {
                    $Interface = 'PBM:Solution WorkLog' 
                    $IDText = 'Solution Database ID'
                }
                Default { 
                    $Interface = 'HPD:WorkLog' 
                    $IDText = 'Incident Number'
                }
            }

            $Filter = @()

            If ($Exact) { $Op = '='; $Wc = '' } Else { $Op = 'LIKE'; $Wc = '%25' }
            If ($Exact -or $IDNum -match '^(INC|CRQ|PBI|PKE|SDB)\d{12}') { $IDOp = '='; $IDWc = '' } Else { $IDOp = 'LIKE'; $IDWc = '%25' }
            
            If ($IDNum)       { $Filter += "'$IDText'$IDOp""$IDWc$IDNum""" }
            If ($Team)        { $Filter += "'Assigned Group'=""$Team""" }
            If ($Title)       { $Filter += "'Description'$Op""$Wc$Title$Wc""" }
            If ($Note)        { $Filter += "'Detailed Description'$Op""$Wc$Note$Wc""" }
            If ($WorkLogType) { $Filter += "'Work Log Type'=""$WorkLogType""" }
            If ($Submitter)   { $Filter += "'Submitter'$Op""$Wc$Submitter$Wc""" }
        
            If ($After)       { $Filter += "'Submit Date'>""$($After.ToString("yyyy-MM-dd"))""" }
            If ($Before)      { $Filter += "'Submit Date'<""$($Before.ToString("yyyy-MM-dd"))""" }

            $FilterString = $Filter -Join 'AND'

            $Headers = @{
                Authorization = "Basic $EncodedCredentials"
            }

            If (-not $FilterString) { Throw 'Please provide at least one search criteria. Enter Help Get-RemedyWorkLog for further guidance.' }

            $URL = "$APIURL/$Interface/$FilterString"
    
    
            Try {
                $Result = Invoke-RestMethod -URI $URL -Headers $Headers -ErrorAction Stop

                $Tickets = @()
                $Result.PSObject.Properties | ForEach-Object { $Tickets += $_.Value }
        
                #Convert all date containing fields to PS datetime
                
                ForEach ($Ticket in $Tickets) { 
                    $Ticket.PSObject.Properties.Name -like '* Date*' | ForEach-Object {
                        #$DateString = $Ticket.$_
                        If ($Ticket.$_ -match 'UTC'){
                            $Ticket.$_ = [datetime]::ParseExact(($Ticket.$_ -Replace 'UTC ',''),'ddd MMM dd HH:mm:ss yyyy',$null)
                        }
                    }
                }
                
                <#Replace this with a format.ps1.xml#>
                If (-not $Full){
                    $Tickets = $Tickets | 
                        Select-Object 'Submit Date','Detailed Description','Submitter','Customer Company',
                                      'Work Log Type','View Access','Assigned Group'
                }

            } Catch {
                Write-Error "Error: $_"
            }

            Write-Output $Tickets
        }
    }
}