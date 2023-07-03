# SecurityTxtToolkit change log

## Not yet released
-  Added a new cmdlet, `Save-SecurityTxtFile`, to simply download a "security.txt" file.
-  Added a new cmdlet, `Find-SecurityTxtFile`, to locate a website's "security.txt" file, to ensure that it is in the correct well-known location instead of the legacy one.
-  Changed how this module interfaces with `gpg`, so that it's more predictable on non-English systems.  Thank you to [Johannes Schöpp](https://github.com/jschpp) for [his great bug report, #3, and pull request, #4](https://github.com/rhymeswithmogul/SecurityTxtToolkit/pull/4).
-  Improved detection of bad signatures.
-  Include RFC 9116 in here as `about_SecurityTxt`.
-  Code cleanup.

## Version 1.3.1 (November 23, 2022) -- I had a busy day.
-  Fixed a bug preventing this module from working on Windows PowerShell 5.1.  The `[HTTPWebRequest].BaseResponse.IsSuccessStatusCode` property was not supported when running under the .NET Framework.

## Version 1.3.0 (November 23, 2022)
-  Added support for verifying digitally-signed "security.txt" files, if GnuPG is available.
-  Made improvements to determining whether or not a file is canonical for a given URL.  The RFC leaves it intentionally vague, so `IsCanonical` is now set if it matches *either* the request URI or the user-supplied URI.

## Version 1.2.0 (November 23, 2022)
-  Add the cmdlet `Get-SecurityTxtFile`.
-  Fixed the user agent so that it shows the current version.
-  Removed all references to "security.txt" being a draft standard, because it's not anymore;  it's RFC 9116!

## Version 1.1.0 (October 25, 2022)
-  Added ShouldProcess support for `New-SecurityTxtFile`. (PSScriptAnalyzer)
-  Refactored `Test-SecurityTxtFile` cmdlet.

## Version 1.0.1
Initial release.