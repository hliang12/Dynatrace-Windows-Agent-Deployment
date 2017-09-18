
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

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition ## fix for BL
		
Write-Host = "Execution Path of the script is : " $scriptPath
		
$FilePathWSService = $scriptPath + '\InstallWSAgentService.ps1'
$FilePathWSModule = $scriptPath + '\InstallWSAgentModuleIIS.ps1'

Write-Host "Installing WS Agent service and configure it..."
#name is agent 
$CONFIG = '{ "Name": "'+$AgentName+'", "Server": "'+$CollectorIP+'", "Loglevel": "info", "isMasterAgentServiceInstalled": "true"}'

#.\InstallWSAgentService.ps1 $DTHOME $CONFIG # changed here 
& FilePathWSService $DTHOME $CONFIG
Write-Host "Done, if no errors" -ForegroundColor green

Write-Host "Installing IIS modules and resetting IIS..."
#.\InstallWSAgentModuleIIS.ps1 $DTHOME -Use64Bit  ## check is this alwyas 64bit? 
#.\InstallWSAgentModuleIIS.#ps1 $DTHOME

& FilePathWSModule $DTHOME -Use64Bit
& FilePathWSModule $DTHOME 
Write-Host "Done, if no errors" -ForegroundColor green


Stop-Service -displayname "Dynatrace Webserver Agent"
Start-Service -displayname "Dynatrace Webserver Agent"

iisreset

Write-Host "Done, if no errors" -ForegroundColor green