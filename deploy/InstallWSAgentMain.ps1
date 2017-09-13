
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$DTHOME,

	[Parameter(Mandatory=$True)]
	[string]$AgentName,
    
    [Switch]$Use64Bit, 

    [Parameter(Mandatory=$True)]
    [string] $CollectorIP
)


Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green



Write-Host "Installing WS Agent service and configure it..."
#name is agent 
$CONFIG = '{ "Name": "'+$AgentName+'", "Server": "'+$CollectorIP+'", "Loglevel": "info", "isMasterAgentServiceInstalled": "true"}'
.\InstallWSAgentService.ps1 $DTHOME $CONFIG # changed here 
Write-Host "Done, if no errors" -ForegroundColor green

Write-Host "Installing IIS modules and resetting IIS..."
.\InstallWSAgentModuleIIS.ps1 $DTHOME -Use64Bit  ## check is this alwyas 64bit? 
.\InstallWSAgentModuleIIS.ps1 $DTHOME
Write-Host "Done, if no errors" -ForegroundColor green


Stop-Service -displayname "Dynatrace Webserver Agent"
Start-Service -displayname "Dynatrace Webserver Agent"

iisreset

Write-Host "Done, if no errors" -ForegroundColor green