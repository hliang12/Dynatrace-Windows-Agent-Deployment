<#
.SYNOPSIS
    Extracts files from an MSI-installer without executing the installer.
.DESCRIPTION
    Doesn't extract files if targetfolder already exists. Wait's until all files are extracted.
.PARAMETER Installer
    Installer file
.PARAMETER InstallPath
    Targetfolder 
        
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Parameter(Mandatory=$True)]
	[string]$Installer
)


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$modulePath = $scriptPath.TrimEnd('y','o','l','p','e','d')

Import-Module "$modulePath/modules/Util.psm1"

Get-FilesFromMSI -Installer $Installer -InstallPath $InstallPath