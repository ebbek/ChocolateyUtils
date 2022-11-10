#! /usr/bin/env pwsh

<# 
   .SYNOPSIS
   Chocolatey package dependency analysis utility.

   .DESCRIPTION
   View dependencies for one or more chocolatey packages.
 
   - Run without parameters to see the dependencies for all installed packages.
   - Provide a package name to see the dependencies for that package.
   - Use the Reverse switch to see what the installed packages are depeneded on. If this list is
     empty for a package and that package is not one that is used, that package can probably be
     uninstalled without harm.

   This utility will access the .nuspec files located in $Env:ChocolateyInstall\lib package subdirectories.

   .INPUTS
   None.
 
   .OUTPUTS
   None.
#>

param (
   # List of packages to examine, separated by commas
   [string[]] $packages,
   # Show reverse dependencies
   [Alias("r")]
   [switch] $Reverse,
   # Print this help text.
   [Alias("h")]
   [switch] $Help
)

# Choco-Dependencies.ps1 Copyleft 2022 by Ebbe Kristensen.
# LICENSE: GNU GPL v3 - https://www.gnu.org/licenses/gpl.html
# Open a GitHub issue at https://github.com/ebbek/ChocolateyUtils/issues if you have suggestions for improvement.

# ImDone Tasks:
# =======================
#
# TODO:0 **{{source.path}}** Consider an output format that can be used in Powershell pipes.
# +deferred

# Check whether Chocolatey is installed
if ( $Env:ChocolateyInstall -eq $Null )
{
   Write-Error "`nIt seems that Chocolatey is not set up correctly. Specifically: The Environment variable `$Env:ChocolateyInstall is not set."
   exit -1
}

# Location of chocolatey package information
$chocodir = "$Env:ChocolateyInstall\lib"

# This class stores the relations as a hashtable of arraylists where the key is the package which
# the elements in the list depend on.
class Relations
{
   # This is where we keep our relations
   hidden [System.Collections.HashTable] $relationsTable = @{}

   # Constructor - redundant?
   Relations()
   {
   }

   # Add a relation
   [void] add_relation( [string] $key, [string] $value )
   {
      # Add to existing list?
      if ( $this.relationsTable.contains( $key ) )
      {
         # Avoid duplicate entries in list of dependents
         if ( ! $this.relationsTable[ $key ].contains( $value ) )
         {
            $this.relationsTable[ $key ].Add( $value )
         }
      }
      else
      {
         # Create a new list
         [System.Collections.ArrayList] $newlist = @( $value )
         $this.relationsTable[ $key ] = $newlist
      }
   }

   # Look up a relation. Returns an ArrayList which may be empty
   [System.Collections.ArrayList] get_relation( [string] $key )
   {
      if ( $this.relationsTable.keys -contains $key )
      {
         # Return what we have
         return $this.relationsTable[ $key ]
      }
      else
      {
         # Return empty list
         [System.Collections.ArrayList] $emptylist = @()
         return $emptylist
      }
   }
}

# Collect all dependencies here
$dependencies = [Relations]::new()

# Collect dependencies for a single package. This function will call itself recursively to collect
# all dependencies.
function Collect-FileDependencies()
{
   param (
      [string] $packagename
      )

   # Is this package installed on this machine
   if ( Test-Path "$chocodir\$packagename\$packagename.nuspec" )
   {
      # Get XML data from .nuspec file
      [xml]$elements = Get-Content -Path "$chocodir\$packagename\$packagename.nuspec"
      # Check for sub-dependencies
      $elements.package.metadata.dependencies.dependency.id | foreach { 
         if ( $Reverse )
         {
            # Collecting reverse dependencies.
            $dependencies.add_relation( $_, $packagename )
         }
         else
         {
            # Collectiong ordinary dependencies.
            $dependencies.add_relation( $packagename, $_ )
         }
         # Go on to collect dependencies for the package that was just added.
         Collect-FileDependencies( "$_" )
      }
   }
}

# Collect dependencies for all installed packages.
function Collect-AllDependencies()
{
   # Iterate over all .nuspec files found in subdirectories of $chocodir
   Get-ChildItem -Recurse "$chocodir\*.nuspec" | foreach {
      # Get dependencies for this package
      Collect-FileDependencies( $_.basename )
   }
}

# Show all dependencies for a package. Dependencies are shown indented (currently hardcoded as two
# spaces).
function Show-FileDependencies()
{
   param (
      [string[]] $packagename
      )

   # Is this package installed on this machine
   if ( Test-Path "$chocodir\$packagename\$packagename.nuspec" )
   {
      # Determine current level of dependencies
      if ( $level -eq $null )
      {
         # Create level number only once
         [int]$level = 1
      }
      else
      {
         $level = $level + 1
      }

      # Create indentation string for each call
      [string] $indent = ""
      # No indentation for level 1
      if ( $level -gt 1 )
      {
         # For other levels, indent two spaces per level
         2..$level | foreach { $indent = "  $indent" }
      }

      # What are we looking at?
      Write-Output "$indent$packagename"
      # Check for sub-dependencies
      $dependencies.get_relation( $packagename ) | foreach { 
         Show-FileDependencies( "$_" )
      }
   }
}

# Add empty line between packages, except before the first one
function Print-EmptyLine()
{
   # Create and initialise control flag only if it does not exist. Must have script scope in order
   # to survive between calls.
   if ( $script:skip_first -eq $null )
   {
      [bool] $script:skip_first = $true
   }

   if ( $script:skip_first )
   {
      $script:skip_first = $false
   }
   else
   {
      Write-Output( " " )
   }
}

# Show dependencies for all installed packages.
function Show-AllDependencies
{
   # Iterate over all .nuspec files found in subdirectories of $chocodir
   Get-ChildItem -Recurse "$chocodir\*.nuspec" | foreach {
      Print-EmptyLine
      # Show dependencies for this package
      Show-FileDependencies( $_.basename )
   }
}

# We collect all dependencies no matter what...
Collect-AllDependencies

if( $Help )
{
   help "$PSCommandPath"
}
elseif ( $packages )
{
   # Iterate over the supplied list of packages
   foreach ( $packagename in $packages )
   {
      Print-EmptyLine
      # Show dependencies for this package
      Show-FileDependencies( $packagename )
   }
}
else
{
   Show-AllDependencies
}

