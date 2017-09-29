<#
.SYNOPSIS
    Instruments all .NET process found in IIS with the .Net Agent
.DESCRIPTION
    Checks if Dynatrace .NET agent is already configured. 
    If yes it rewrites it's configuration. 
    If there's already 3rd party .NET profiler configured, Dynatrace .NET agent installation is skipped.
.PARAMETER DTHOME
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <DTHOME>\agent\lib\dtagent.dll
.PARAMETER SystemProfile
   System Profile that the agent will match against
.PARAMETER CollectorIP
    <HostnameOrIP>[:Port]
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent

#>
[CmdletBinding()]
param(
	#[Parameter(Mandatory=$True)]
	#[string]$ProcesseEngineName,
	
	[Parameter(Mandatory=$True)]
	[string]$DTHOME,
	
    [Switch]$Use64Bit, 
	
	[Parameter(Mandatory=$True)]
    [string] $SystemProfile,
	
    [Parameter(Mandatory=$True)]
    [string] $CollectorIP
	
)

Write-Host "Set-ExecutionPolicy..."
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green

#$currentDir = pwd
$appcmd = [System.Environment]::GetEnvironmentVariable("windir") + "\system32\inetsrv\appcmd.exe"
#cd inetsrv

##$appPools = .\appcmd.exe list app ## or list wp

$appPools = iex "$appcmd list apppool" 

$appPoolList = $appPools -split "\n" ## 

#$temp = iex "$appcmd list apppool" 

#$appPoolListVer = $temp -split "\n"

for($i=0; $i -lt $appPoolList.length; $i++){

	#$getAppversion = $appPoolList[$i] -match 'MgdVersion:v(.*),Mgd'
	#$testVersion = $matches[1] -as[Double]
	
	#if($testVersion -lt 3.5){
	
	#	$unsupportedApp = $appPoolList[$i] -match 'APPPOOL "(.*)"' 
	#	Write-Host $matches[1] "is running an outdated version of .net, it's running version: " $testVersion
		
	#}else{
	
		Write-Host "Getting AppPool Names"
		$temp = $appPoolList[$i] -match 'APPPOOL "(.*)"' ### regex out the process name 
		Write-Host "Setting up agent for " $matches[1] 
		$appName = $matches[1] -replace '\s',''
        $processName = $matches[1]
		$agentName = $appName + "_" + $SystemProfile
		
		Write-Host "Agent name is :" $agentName
		
		$processEngineString = '[ "w3wp.exe -ap ' + '\"' +$processName+'\"" ]'
		
		Write-Host = "Process Engine String is : " $processEngineString
		
		$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
		
		Write-Host = "Execution Path of the script is : " $scriptPath
		
		$FilePath = $scriptPath + '\InstallDotNetAgent.ps1'
		
		Write-Host = "Instrumenting .NET Process now" 
		Write-Host = $agentName +" " + $CollectorIP
		
	    & $FilePath $DTHOME $agentName $CollectorIP -Use64Bit $processEngineString
		
	#}
	
}

















