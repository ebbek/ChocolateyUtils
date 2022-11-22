# ChocolateyUtils
Utilities for Chocolatey

This project contains my Chocolatey utilities, all written in the PowerShell script language.

## choco-dependencies.ps1

### Purpose

The purpose of ```choco-dependencies``` is:

- To show the dependencies of one or more of the Chocolatey packages that are installed on your
  system or...
- To show which packages depend on one or more of the Chocolatey packages that are installed on
  your system.

### Usage

If ```choco-dependencies``` is started without any package names supplied, it will show the
dependencies or dependants of all packages. You may select one or more packages as follows:

```PowerShell
choco-dependencies packagenamelist
```

where:
```EBNF
packagenamelist := packagename [, packagenamelist]
```

To show dependants, run the utility as follows:
```PowerShell
choco-dependencies -Reverse [packagenamelist]
``` 

### How it works

This utility goes through the following stages:

1. Checks whether it is running on Windows  and exits if it isn't. Chocolatey is Windows-only so
   it makes no sense to allow running on other platforms.
2. Uses the environment variable ```ChocolateyInstall``` to find the Chocolatey ```lib```
   directory.
3. Here it scans all ```.nuspec``` files in all subdirectories for dependencies and stores them as
   ```arraylists``` in a ```hashtable```. The ```-Reverse``` option determines how the dependencies
   are stored:
   - If not set, the module being scanned is used as index in the ```hashtable``` and the dependency
     is stored in the ```arraylist``` it indexes.
   - If set, the dependency is used as index and the module being scanned is stored in the ```arraylist```
     it indexes.
4. And finally it shows the dependencies for the modules that you have chosen.

### Notes

Output is text-only. This may change to be some kind of object (to make it more "powershell'y") but
so far I have not found out what that should be.

