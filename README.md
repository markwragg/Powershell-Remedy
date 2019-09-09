# Powershell-Remedy

[![Build Status](https://dev.azure.com/markwragg/GitHub/_apis/build/status/markwragg.Powershell-Remedy?branchName=master)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=6&branchName=master) ![Test Coverage](https://img.shields.io/badge/coverage-82%25-yellow.svg?maxAge=60)

This project is a PowerShell module for interacting with the BMC Remedy ARS Rest API. It has been tested against a system that is running Remedy v9. Results with other versions/implementations of Remedy may vary.

## Getting Started

After installation, you will need to set your Remedy API URL and credentials. You do this by running:

    Set-RemedyAPIConfig -APIURL https://yourremedy.url.whatever/arapi/yourmidtearserver -IncidentURL https://yourremedy.url.whatever/arsys/forms/cmdbapppd/HPD:Help%20Desk
    
Which will then prompt you to enter credentials. These are saved as an encrypted string to your userprofile directory by default (you can redirect this by using `-File`).

## Examples

### Get-RemedyTicket

You can get a specific (incident) ticket by partial or full Incident Number as follows:

    Get-RemedyTicket -ID 12345

This will return a small object with a default set of frequently needed properties available. To return an object with all of the properties available via the API add the `-Full` switch:

    Get-RemedyTicket -ID 12345 -Full

There are many other parameters for filtering/retrieving resuts in other ways e.g by `-Team`, `-Submitter`, `-Customer` etc. Enter `Help Get-RemedyTicket -Full` for full details.

### Get-RemedyChange

You can get a specific Remedy Change by full or partial Change ID Number as follows:

    Get-RemedyChange -ID 12345
    
This will return a small object with a default set of frequently needed properties available. To return an object with all of the properties available via the API, add the `-Full` siwtch:

    Get-RemedyChange -ID 12345 -Full
    
There are many other parameters for filtering/retrieving resuts in other ways e.g by `-Team`, `-Submitter`, `-Customer` etc. Enter `Help Get-RemedyChange -Full` for full details.

### Get-RemedyProblem

You can get a specific Remedy Problem record by full or partial Problem ID Number as follows:

    Get-RemedyProblem -ID 12345
    
This will return a small object with a default set of frequently needed properties available. To return an object with all of the properties available via the API, add the `-Full` siwtch:

    Get-RemedyProblem -ID 12345 -Full
    
There are many other parameters for filtering/retrieving resuts in other ways e.g by `-Team`, `-Submitter`, `-Customer` etc. Enter `Help Get-RemedyProblem -Full` for full details.

### Get-RemedySolution

You can get a specific Remedy Solution record by full or partial Solution ID Number as follows:

    Get-RemedySolution -ID 12345
    
This will return a small object with a default set of frequently needed properties available. To return an object with all of the properties available via the API, add the `-Full` siwtch:

    Get-RemedySolution -ID 12345 -Full
    
There are many other parameters for filtering/retrieving resuts in other ways e.g by `-Team`, `-Submitter`, `-Customer` etc. Enter `Help Get-RemedySolution -Full` for full details.

### Get-RemedyKnownError

You can get a specific Remedy Known Error record by full or partial Known Error ID Number as follows:

    Get-RemedyKnownError -ID 12345
    
This will return a small object with a default set of frequently needed properties available. To return an object with all of the properties available via the API, add the `-Full` siwtch:

    Get-RemedyKnownError -ID 12345 -Full
    
There are many other parameters for filtering/retrieving resuts in other ways e.g by `-Team`, `-Submitter`, `-Customer` etc. Enter `Help Get-RemedyKnownError -Full` for full details.

### Get-RemedyWorkLog

You can get the worklog entries associated with a ticket (Incident/Request) by doing the following:

    Get-RemedyTicket -ID 12345 | Get-RemedyWorkLog

You can get the worklog entries associated with a Change by doing one of the following:

    Get-RemedyChange -ID 12345 | Get-RemedyWorkLog
    Get-RemedyWorkLog -ID 12345 -Type Change
    
You can get the worklog entries associated with a Problem by doing one of the following:

    Get-RemedyProblem -ID 12345 | Get-RemedyWorkLog
    Get-RemedyWorkLog -ID 12345 -Type Problem

You can get the worklog entries associated with a Solution by doing one of the following:

    Get-RemedySolution -ID 12345 | Get-RemedyWorkLog
    Get-RemedyWorkLog -ID 12345 -Type Solution

You can get the worklog entries associated with a Known Error by doing one of the following:

    Get-RemedyKnownError -ID 12345 | Get-RemedyWorkLog
    Get-RemedyWorkLog -ID 12345 -Type KnownError
    
You can filter for a specific type of worklog by specifying `-WorkLogType`. E.g:

    Get-RemedyChange -ID 12345 | Get-RemedyWorkLog -WorkLogType 'Resolution'
    
There are many other parameters for filtering the results of `Get-RemedyWorkLog`. Enter `Help Get-RemedyWorkLog -Full` to learn more.
    
### Get-RemedyTeam

You can get the members of a specified Remedy Support Team with this command.

    Get-RemedyTeam -Name Windows
    
This actually makes two calls to the API, it queries the `CTM:Support Group` schema to get the ID of the Support Group, then uses this to query the `CTM:Support Group Association` schema to get it's associated members.

### Get-RemedyPerson

This returns the details of a person from Remedy. This can be a customer or a member of staff:

    Get-RemedyPerson -Name 'Joe Bloggs'
    
The cmdlet searches the 'Full Name' field and partial strings are accepted:

    Get-RemedyPerson -Name 'John Sm'

If you wish to only return Staff members you can use the `-Staff` switch to filter the result to just these:

    Get-RemedyPerson -Name 'Tony Stark' -Staff

### Get-RemedyInterface

You can see a list of available Remedy interfaces/forms by running:

    Get-RemedyInterfaces
    
This command is just helpful if you want to explore the API, understand the schema/fields and potentially extend this module.
