[![PowerShell Gallery Version (including pre-releases)](https://img.shields.io/powershellgallery/v/SecurityTxtToolkit?include_prereleases)](https://powershellgallery.com/packages/SecurityTxtToolkit/) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/SecurityTxtToolkit)](https://powershellgallery.com/packages/v/SecurityTxtToolkit)

# SecurityTxtToolkit

## DOWNLOAD IT!
[It's in the PowerShell Gallery now!](https://www.powershellgallery.com/packages/SecurityTxtToolkit/)
```powershell
Install-Module SecurityTxtToolkit
```

## SHORT DESCRIPTION
SecurityTxtToolkit is a module that works with "security.txt" files, as defined in RFC 9116.

## LONG DESCRIPTION
SecurityTxtToolkit is a PowerShell module.   It can create, download, test, and verify "security.txt" files.

"security.txt" is a draft RFC for letting  web sites post and share information pertinent to security researchers.  This module currently complies with draft version 12.

### Testing "security.txt" Files with `Test-SecurityTxtFile`
To test a "security.txt" file, use the cmdlet `Test-SecurityTxtFile`.  It can be used in both online and offline modes.  It outputs a `PSCustomObject` that has note-properties corresponding to the fields in the "security.txt" file:

```powershell
PS C:\> Test-SecurityTxtFile 'github.com'
```

As of this writing (June 2021), that will generate the following output:
```
Test-SecurityTxtFile: The mandatory Expires field was not found.

For                : github.com
IsValid            : False
IsCanonical        : True
Acknowledgements   : {https://bounty.github.com/bounty-hunters.html}
Canonical          : {https://github.com/.well-known/security.txt}
Contact            : {https://hackerone.com/github}
Encryption         : {}
Expires            :
Hiring             : {}
Policy             : {https://bounty.github.com/}
PreferredLanguages : {en}
IsSigned           : False
```

It looks like GitHub's "security.txt" file is not compliant with the latest version of the draft specification!

The `Test-SecurityTxtFile` cmdlet also accepts string input via `-InputObject` or the pipeline:
```powershell
PS C:\> Get-Content "security.txt" | Test-SecurityTxtFile
```

That will test the file and validate its input:
```
For                : stdin
IsValid            : False
IsCanonical        : False
Acknowledgements   : {https://bounty.github.com/bounty-hunters.html}
Canonical          : {https://github.com/.well-known/security.txt}
Contact            : {https://hackerone.com/github}
Encryption         : {}
Expires            :
Hiring             : {}
Policy             : {https://bounty.github.com/}
PreferredLanguages : {en}
IsSigned           : False
```

However, that cannot be validated for canonicity. In this case, you can add the file's original URL to the cmdlet with the `-TestCanonicalUri` parameter:
```powershell
PS C:\> Invoke-WebRequest -OutFile 'security.txt' -Uri 'https://github.com/.well-known/security.txt'

PS C:\> Get-Content 'security.txt' | Test-SecurityTxtFile -TestCanonicalUri 'https://github.com/.well-known/security.txt'
```

The latter command will parse the previously-downloaded "security.txt" file as if it had been fetched directly from a web server:
```
For                : stdin
IsValid            : False
IsCanonical        : True
Acknowledgements   : {https://bounty.github.com/bounty-hunters.html}
Canonical          : {https://github.com/.well-known/security.txt}
Contact            : {https://hackerone.com/github}
Encryption         : {}
Expires            :
Hiring             : {}
Policy             : {https://bounty.github.com/}
PreferredLanguages : {en}
IsSigned           : False
```

### Generating Your Own "security.txt" Files
The `New-SecurityTxtFile` cmdlet will generate a "security.txt" file, sending its output to the pipeline. You may redirect it via standard means, or with the `-OutFile` parameter.   The fields in the "security.txt" specification correspond to this cmdlet's parameters.
```powershell
PS C:\> New-SecurityTxtFile -OutFile '.well-known/security.txt' -Canonical "https://contoso.com/.well-known/security.txt" -Contact "mailto:security@contoso.com" -Hiring "https://jobs.contoso.com"
```

That example will genereate the following output. The Expires field and PGP signature will vary:
```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

# This is a "security.txt" file that complies with draft-foudil-securitytxt-12:
# <https://datatracker.ietf.org/doc/html/draft-foudil-securitytxt-12>
#
# This file was made with SecurityTxtToolkit:
# <https://github.com/rhymeswithmogul/security-txt-toolkit>

Canonical: https://contoso.com/.well-known/security.txt
Contact: mailto:security@contoso.com
Expires: 2022-06-18T16:41:06-04:00
Hiring: https://jobs.contoso.com/

-----BEGIN PGP SIGNATURE-----

iHUEARYKAB0WIQQ7NZ6ap/Bjr/sGU4FSrfh98PoTfwUCYNvzBwAKCRBSrfh98PoT
f8siAP9hOryAzTmjXC7zfEwoz/JwypS8aN+c1rqdFDFt9w8DoAEA30rxuhQDv56v
bCbTyst2GEBxCy8b1+2fs0iF9WQVWws=
=Wzju
-----END PGP SIGNATURE-----
```

## SEE ALSO
For more information about "security.txt" files in general, the creators of the specification, Edwin "EdOverflow" Foudil and Yakov Shafranovich, have a web page at https://securitytxt.org.  This module might be listed on their web site, but I'm not affiliated with them.
