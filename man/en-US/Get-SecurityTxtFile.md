---
external help file: SecurityTxtToolkit-help.xml
Module Name: SecurityTxtToolkit
online version: https://github.com/rhymeswithmogul/SecurityTxtToolkit/blob/main/man/en-US/Get-SecurityTxtFile.md
schema: 2.0.0
---

# Get-SecurityTxtFile

## SYNOPSIS
Fetches a domain's "security.txt" file.

## SYNTAX

```
Get-SecurityTxtFile [-Domain] <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet fetches a domain's "security.txt" file from the well-known location, as well as from the legacy /security.txt location.  For testing purposes, it can also fetch over HTTP, but the user will be warned.  No post-processing is done on the file, and it is displayed on the screen.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-SecurityTxtFile securitytxt.org
```

Returns the securitytxt.org "security.txt" file.

## PARAMETERS

### -Domain
The domain name to check for a "security.txt" file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DomainName, Host, HostName, Name, Uri, Url

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
One or more domain names.

## OUTPUTS

### System.String
A website's "security.txt" file is shown on the screen, and can be passed down the pipeline.

## NOTES

## RELATED LINKS

[Test-SecurityTxtFile](Test-SecurityTxtFile)
[GitHub](https://github.com/rhymeswithmogul/SecurityTxtToolkit)
[RFC 9116: A File Format to Aid in Security Vulnerability Disclosure](https://www.rfc-editor.org/rfc/rfc9116)