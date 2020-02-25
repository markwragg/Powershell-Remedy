# Test-RemedyApiConfig

## SYNOPSIS
Tests credentials and URL for use with the Remedy API.

## SYNTAX

```
Test-RemedyApiConfig [[-Path] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Use this cmdlet to validate your Remedy API credentials.

## EXAMPLES

### EXAMPLE 1
```
Test-RemedyAPIConfig
```

Uses the Remedy API config in your userprofile to test the credentials are valid.

## PARAMETERS

### -Path
Path to your Remedy API config file.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES

## RELATED LINKS
