
[CmdletBinding()]
param(
	#[Parameter(Mandatory=$True)]
	#[string]$ProcesseEngineName,
	
	[Parameter(Mandatory=$True)]
	[string]$DTHOME,
	
    [Switch]$Use64Bit, 

    [Parameter(Mandatory=$True)]
    [string] $CollectorIP,
	
	[Parameter(Mandatory=$True)]
	[string]$AgentName,
	
	[Parameter(Mandatory=$True)]
    [string] $ProcessEngine  ### check on process engine name  [ "PT001.exe -ap \"myDotNet\"" ]'
	
)


Write-Host "-----------------------------------------------------------------" -ForegroundColor green
Write-Host "--              Dynatrace LLC                                  --" -ForegroundColor green
Write-Host "--              Hao-lin Liang                             --" -ForegroundColor green
Write-Host "-----------------------------------------------------------------" -ForegroundColor green

Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green

Write-Host "Collector IP is $CollectorIP"

Write-Host "Install dir is $DTHOME"

$processEngineString = '[ "w3wp.exe -ap ' + '\"' +$ProcessEngine+'\"" ]'

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
		
Write-Host = "Execution Path of the script is : " $scriptPath
		
$FilePath = $scriptPath + '\InstallDotNetAgent.ps1'

#.\InstallDotNetAgent.ps1 $DTHOME '$AgentName' '$CollectorIP' -Use64Bit '[ "w3wp.exe -ap \"$ProcessEngine\""]'

& FilePath $DTHOME $AgentName $CollectorIP -Use64Bit $processEngineString

iisreset