# ChocolateyUtils
Utilities for Chocolatey

This project contains my Chocolatey utilities, all written in the PowerShell script language.

## Choco-Dependencies.ps1

The purpose of ```Choco-Dependencies``` is:

- To show the dependencies of one or more of the Chocolatey packages that are installed on your
  system.
- To show which packages depend on one or more of the Chocolatey packages that are installed on
  your system.

If ```Choco-Dependencies``` is started without any package names supplied, it will show the
dependencies or dependants of all packages. You may select one or more packages as follows:

```ps1
Choco-Dependencies packagenamelist
```

where:
```bnf
packagenamelist := packagename [, packagenamelist]
```

To show dependants, run the utility as follows:
```ps1
Choco-Dependencies -Reverse [packagenamelist]
``` 

