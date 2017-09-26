<#
.SYNOPSIS
    Enables Dynatrace .NET agent.
.DESCRIPTION
    Checks if Dynatrace .NET agent is already configured. 
    If yes it rewrites it's configuration. 
    If there's already 3rd party .NET profiler configured, Dynatrace .NET agent installation is skipped.
.PARAMETER DTHOME
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <DTHOME>\agent\lib\dtagent.dll
.PARAMETER AgentName
    Agent's name as shown in Dynatrace
.PARAMETER CollectorIP
    <HostnameOrIP>[:Port]
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent
.PARAMETER ProcessEngine
    JSON string array of processes to whitelist. Optionally supports process arguments. e.g. "w3wp.exe -ap \"<ProcessEngine>\""
.NOTE 
    NOTE: If NO processes are whitelisted, agent instruments ALL .NET processes when they are started!
#>
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