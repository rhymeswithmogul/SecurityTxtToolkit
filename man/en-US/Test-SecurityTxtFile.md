---
external help file: SecurityTxtToolkit-help.xml
Module Name: SecurityTxtToolkit
online version: https://github.com/rhymeswithmogul/security-txt-toolkit/blob/main/man/en-US/Test-SecurityTxtFile.md
schema: 2.0.0
---

# Test-SecurityTxtFile

## SYNOPSIS
Parses and validates a "security.txt" file.

## SYNTAX

### Online (Default)
```
Test-SecurityTxtFile [[-Domain] <String>] [<CommonParameters>]
```

### Offline
```
Test-SecurityTxtFile [-InputObject] <String[]> [[-TestCanonicalUri] <Uri>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will parse a "security.txt" file for completeness and correctness.  You can pass the content of a downloaded "security.txt" file directly into this cmdlet, or give it a domain name and it will download it from the web site.

## EXAMPLES

### Example 1
```powershell
PS C:\> Test-SecurityTxtFile -Domain 'securitytxt.org'
```

This will download the "security.txt" file for the domain securitytxt.org -- https://securitytxt.org/.well-known/security.txt -- parse it, and check its validity.

### Example 2
```powershell
PS C:\> Get-Content './Downloads/security.txt' | Test-SecurityTxtFile -TestCanonicalUri 'https://securitytxt.org/.well-known/security.txt'
```

If you have already downloaded a "security.txt" file, you can pipe its content into this cmdlet.  To ensure that this file is canonical, you may specify the URL from where it was downloaded.  The latter parameter is optional, though.

## PARAMETERS

### -Domain
To download a "security.txt" file from a web server, specify it here.  The cmdlet will check for this file in the "/.well-known" folder before falling back to the compatibility location ("/").

```yaml
Type: String
Parameter Sets: Online
Aliases: DomainName, Host, HostName, Name, Uri, Url

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObject
To validate an offline "security.txt" file, use this parameter to specify the contents, either explicitly or via the pipeline.

```yaml
Type: String[]
Parameter Sets: Offline
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TestCanonicalUri
A previously-downloaded "security.txt" file cannot be verified to ensure that it is canonical.  If you would to test canonicity, specify the complete URL to where the "security.txt" would be if online.  If this URI matches one of the `Canonical` URI's in the "security.txt" file, then it is canonical.

```yaml
Type: Uri
Parameter Sets: Offline
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
When using this cmdlet to download a "security.txt" file from a domain, you may pass in a single string (by property name).

### System.String[]
When using this cmdlet to parse a downloaded "security.txt" file, pass the contents into this cmdlet (by value).

## OUTPUTS

### System.Management.Automation.PSObject
A hashtable with all of the "security.txt" fields and information will be sent down the pipeline.

## NOTES
This module is compliant with version 12 of the "security.txt" draft.   Note that this standard is currently in a draft phase, and is subject to change at any time.

## RELATED LINKS
[Get-SecurityTxtFile](Get-SecurityTxtFile)
[New-SecurityTxtFile](New-SecurityTxtFile)
[GitHub](https://github.com/rhymeswithmogul/security-txt-toolkit)
[A File Format to Aid in Security Vulnerability Disclosure (draft-foudil-securitytxt-12)](https://datatracker.ietf.org/doc/html/draft-foudil-securitytxt)
