<#
.SYNOPSIS
    Installs Dynatrace (master) Webserver Agent as Windows Service. 
.DESCRIPTION
    If service already installed, configuration is updated. If configuration has changed, service will be restarted.
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Configuration is referenced relative from this directory <InstallPath>\agent\conf\dtwsagent.ini
.PARAMETER JSONConfig
    JSON string containing an object with the the configuration. 
    Example:
    '{ "Name": "IIS", "Server": "localhost", "Loglevel": "info" }'
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Parameter(Mandatory=$True)]
	
	[string]$JSONConfig # Sample: { Name: "IIS", Server: "localhost", Loglevel: "info" }
)

# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false

Import-Module "../modules/Util" 
Import-Module "../modules/InstallWebserverAgent" 


$ServiceName = "Dynatrace Webserver Agent"

$cfg = ConvertFrom-Json20 $JSONConfig

if (!(Test-Path "$InstallPath\agent\conf\dtwsagent.ini")) {
	"Backup fresh install dtwsagent.ini"
	Copy-Item $InstallPath\agent\conf\dtwsagent.ini $InstallPath\agent\conf\dtwsagent.ini.backup
	"Complete."
}

#convert json object into hashtable
$hashTable = $cfg.psobject.properties | foreach -begin {$h=@{}} -process {$h."$($_.Name)" = $_.Value} -end {$h}

if ((Test-ServiceInstallation $ServiceName) -eq $FALSE)
{
	Set-WebserverAgentConfiguration $InstallPath $hashTable 
    Install-WebserverAgentService $ServiceName $InstallPath 
}
else
{

	"Overwritting current settings..."
	Set-WebserverAgentConfiguration $InstallPath $hashTable 
	"Complete."
    #$iniContent = Get-IniContent "$InstallPath\agent\conf\dtwsagent.ini"
    
    #$configChanged = $FALSE
    #"Checking configuration changes..."
	#foreach ($e in $hashTable.GetEnumerator()) 
    #{
	#	 "Validate key '$($e.Name)'..."
    #     if ($iniContent[$e.Name] -ne $e.Value)
    #     {
    #        "mismatch."
    #        Set-WebserverAgentConfiguration $InstallPath $hashTable
    #        "Restarting Webserver Agent..."
    #        Restart-Service $ServiceName
	#
    #       $configChanged = $TRUE
    #       break;
    #     }
    #     else
    #     {
    #        "Ok."
    #     }
	#}
    #if ($configChanged -eq $FALSE)
    #{
    #    "Resetting" 
    #}

    
}

Remove-Module Util
Remove-Module InstallWebserverAgent

