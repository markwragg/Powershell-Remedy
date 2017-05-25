# Powershell-Remedy

[![Build status](https://ci.appveyor.com/api/projects/status/8ph5oelqby89gaxr?svg=true)](https://ci.appveyor.com/project/markwragg/powershell-remedy)

This project is a PowerShell module for interacting with the BMC Remedy ARS Rest API. It has been tested against a system that is running Remedy v9. Results with other versions/implementations of Remedy may vary.

## Getting Started

This module is published in the Gallery so if you are running PowerShell 5, you can install the Remedy module from the PowerShell Gallery via:

    Install-Module -Name Remedy

Alternatively use the download/clone button to download the module folder from this repo on to your computer into your `modules` directory and then load it with:

    Import-Module Remedy
    
Following this, you will need to set your Remedy API URL and credentials. You can do this by running:

    `Set-RemedyApiConfig -APIURL https://yourserver.example.com/api/whatever
    
Which will then prompt you to enter credentials. These are saved as an encrypted string to your userprofile directory by default (you can redirect this by using `-File`).

## Examples

### Get-RemedyTicket

You can get a specific (incident) ticket by partial or full Incident Number as follows:

    Get-RemedyTicket -ID 12345

This will return a small object with a default set of frequently needed properties available. To return an object with all of the properties available via the API add the `-Full` switch:

    Get-RemedyTicket -ID 12345 -Full

### Get-RemedyWorkLog

You can get the worklog entries associated with a ticket by doing the following:

   Get-RemedyTicket -ID 12345 | Get-RemedyWorkLog

### Get-RemedyInterface

You can see a list of available Remedy interfaces/forms by running:

    Get-RemedyInterfaces
    
This is just helpful if you want to explore the API and potentially extend the module.


