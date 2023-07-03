---
external help file: SecurityTxtToolkit-help.xml
Module Name: SecurityTxtToolkit
online version: https://github.com/rhymeswithmogul/SecurityTxtToolkit/blob/main/man/en-US/New-SecurityTxtFile.md
schema: 2.0.0
---

# New-SecurityTxtFile

## SYNOPSIS
Creates a "security.txt" file.

## SYNTAX

```
New-SecurityTxtFile [[-OutFile] <File>] [-Acknowledgments <Uri[]>] [-Canonical <Uri[]>] -Contact <Uri[]>
 [-Encryption <Uri[]>] [-Expires <DateTime>] [-Hiring <Uri[]>] [-Policy <Uri[]>]
 [-PreferredLanguages <String[]>] [-DoNotSign] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will generate a syntactically-valid "security.txt" file that can be used on web servers.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-SecurityTxtFile -OutFile '.well-known/security.txt' -Canonical "https://contoso.com/.well-known/security.txt" -Contact "mailto:security@contoso.com" -Hiring "https://jobs.contoso.com"
```

This will create a "security.txt" file in the .well-known folder in the current directory.  It will have Canonical, Contact, Expires, and Hiring fields inside.

## PARAMETERS

### -Acknowledgments
This field indicates a link to a page where security researchers are recognized for their reports.  The page being referenced should list security researchers that reported security vulnerabilities and collaborated to remediate them.  Organizations should be careful to limit the vulnerability information being published in order to prevent future attacks.

```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases: Acknowledgements

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Canonical
This field indicates the canonical URIs where the "security.txt" file is located, which is usually something like "https://example.com/.well-known/security.txt".

While this field indicates that a "security.txt" retrieved from a given URI is intended to apply to that URI, it MUST NOT be interpreted to apply to all canonical URIs listed within the file. Researchers SHOULD use an additional trust mechanism such as a digital signature (as per Section 3.3) to make the determination that a particular canonical URI is applicable.

If this field appears within a "security.txt" file, and the URI used to retrieve that file is not listed within any canonical fields, then the contents of the file SHOULD NOT be trusted.

```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases: Uri, Url

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Contact
This field indicates an address that researchers should use for reporting security vulnerabilities such as an email address, a phone number and/or a web page with contact information.

You may use any URI scheme here except for `http:`.  Some examples include:
-   `mailto:` for an email address,
-   `tel:` for a phone number,
-   `https:` for a contact form or other web page, or
-   `MSTeams:` for starting a private Teams chat.

The precedence SHOULD be in listed order.  The first occurrence is the preferred method of contact.


```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotSign
By default, this cmdlet will try to invoke the `gpg` command to sign the "security.txt" file.  If you do not have GnuPG installed, or if you do not wish to sign the file, specify this parameter.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Encryption
This field indicates an encryption key that security researchers should use for encrypted communication.  Keys MUST NOT appear in this field - instead the value of this field MUST be a URI pointing to a location where the key can be retrieved.

URI schemes commonly used here include:
-   `https:` for linking to Web content,
-   `dns:` for serving OPENPGPKEY or other DNS records, and
-   `openpgp4fpr:` for embedding a key's fingerprint.

```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Expires
This field indicates the date and time after which the data contained in the "security.txt" file is considered stale and should not be used.

It is recommended that the value of this field be less than a year into the future to avoid staleness.  In fact, if you do not specify this parameter, this cmdlet will set Expires to exactly one year in the future.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hiring
The "Hiring" field is used for linking to the vendor's security-related job positions.

```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
To save the "security.txt" information to a file, specify this parameter with the path of a file.

```yaml
Type: File
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy
This field indicates a link to where the vulnerability disclosure policy is located.  This can help security researchers understand the organization's vulnerability reporting practices.

```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreferredLanguages
This field is used to indicate a set of natural languages that are preferred when submitting security reports.  The values within this set are language tags (as defined in RFC 5646).  If this field is absent, security researchers may assume that English is the language to be used.

The order in which they are listed is not an indication of priority; the
listed languages are intended to have equal priority.

For example, if your security response team speaks English, Spanish, and French, you may specify a value of `'en','es','fr'`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Languages, Preferred-Languages

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String
This cmdlet will pass the "security.txt" data down the pipeline, if `-OutFile` is not used.

### System.Void
This cmdlet will generate no pipeline output if the `-OutFile` parameter is used.

## NOTES
While you may use any URI scheme for any parameters that accept URIs, there is one exception:  you *must never* use an HTTP URI.  Those are verboten by the specification.  When specifying a Web URI, always use HTTPS.

## RELATED LINKS

[Get-SecurityTxtFile](Get-SecurityTxtFile)
[Test-SecurityTxtFile](Test-SecurityTxtFile)
[GitHub](https://github.com/rhymeswithmogul/SecurityTxtToolkit)
[RFC 9116: A File Format to Aid in Security Vulnerability Disclosure](https://www.rfc-editor.org/rfc/rfc9116)