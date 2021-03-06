﻿<#
.SYNOPSIS
    Enables Dynatrace Webserver (slave) agent in IIS as a native module named 'Dynatrace Webserver Agent'
.DESCRIPTION
    Checks if module is already installed. If 
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER -Use64Bit
    Switch to force usage of 64-bit agent
.Parameter -ForceIISReset
    Switch to force restart of IIS (only if module hasn't already been installed) 
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Switch]$Use64Bit, 

    [Switch]$ForceIISReset
)

# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition  ### fix for using BL

$modulePath = $scriptPath.TrimEnd('y','o','l','p','e','d')

Import-Module "$modulePath/modules/Util.psm1"
Import-Module "$modulePath/modules/InstallWebserverAgent.psm1"

$appcmd = [System.Environment]::GetEnvironmentVariable("windir") + "\system32\inetsrv\appcmd.exe"

"Checking IIS module configuration..."
$xmlStr = iex "$appcmd list module /xml"  

#$xmlObj = [xml]$xmlStr 
#$loadedModules = $xmlObj.SelectNodes("//appcmd/MODULE[contains(@MODULE.NAME,'Dynatrace')]") | select MODULE.NAME | Select-Object -ExpandProperty 'MODULE.NAME'

if ($xmlStr -match 'Dynatrace')
{
	    "IIS Agent module already added - installation skipped."
}
else
{
    "No IIS Agent module found."
    Install-WebserverAgentModuleIIS $InstallPath $Use64Bit 

    if ($ForceIISReset)
    {
        "Restart IIS"
        Wait-For "iisreset"
        iex "net start w3svc"
    }
}

