﻿<#
.SYNOPSIS
    Enables Dynatrace .NET agent.
.DESCRIPTION
    Checks if Dynatrace .NET agent is already configured. 
    If yes it rewrites it's configuration. 
    If there's already 3rd party .NET profiler configured, Dynatrace .NET agent installation is skipped.
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER AgentName
    Agent's name as shown in Dynatrace
.PARAMETER CollectorHost
    <HostnameOrIP>[:Port]
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent
.PARAMETER JSONProcessList
    JSON string array of processes to whitelist. Optionally supports process arguments. e.g. "w3wp.exe -ap \"DefaultAppPool\""
	Example: '[ "w3wp.exe", "WaWorkerHost.exe", "WaWebHost.exe" ]'
    NOTE: If NO processes are whitelisted, agent instruments ALL .NET processes when they are started!
.NOTE 
    NOTE: If NO processes are whitelisted, agent instruments ALL .NET processes when they are started!
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
    [Parameter(Mandatory=$True)]
    [string]$AgentName, 
    
    [Parameter(Mandatory=$True)]
    [string]$CollectorHost, 
    
    [Switch]$Use64Bit, 
	
    [string] $JSONProcessList
)

Write-Host = $CollectorHost + " should be the collector ip"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition  ### fix for using BL

$modulePath = $scriptPath.TrimEnd('y','o','l','p','e','d')

Import-Module "$modulePath/modules/Util.psm1" 
Import-Module "$modulePath/modules/InstallDotNETAgent.psm1" 

# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false

$res = Test-DotNETAgentInstallation
if ($res -ge 0)
{
    if ($res -eq 1)
    {
        "Resetting .NET configuration... "
        #Remove-WhitelistedProcesses
    }

    $ProcessList = ConvertFrom-Json20 $JSONProcessList

    Enable-DotNETAgent $InstallPath $AgentName $CollectorHost $Use64Bit $ProcessList
    
}
else
{
    "Skipped setup of .NET agent - another profiler already configured."
}

