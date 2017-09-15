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

#check for CLR version if its below 2.0.50727.8669

$major = $PSVersionTable.CLRVersion.Major
$minor = $PSVersionTable.CLRVersion.Minor
$build = $PSVersionTable.CLRVersion.Build
$revision = $PSVersionTable.CLRVersion.Revision

if($major -lt 2 ){
	Write-Host "Cannot Instrument appPools as CLR version below  2.0.50727.1433 currently on version: "
	Write-Host "Version " $major"."$minor"."$build"."$revision
	exit 1
}elseif( $build -lt 50727 ){
	Write-Host "Cannot Instrument appPools as CLR version below  2.0.50727.1433 currently on version: "
	Write-Host "Version " $major"."$minor"."$build"."$revision	
	exit 1
}elseif( $revision -lt 1433 ){
	Write-Host "Cannot Instrument appPools as CLR version below  2.0.50727.1433 currently on version: "
	Write-Host "Version " $major"."$minor"."$build"."$revision	
	exit 1
}else{
	Write-Host "Version of dotnet is fine"
}

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
	
		$temp = $appPoolList[$i] -match 'APPPOOL "(.*)"' ### regex out the process name 
		Write-Host "Setting up agent for " $matches[1] 
		$appName = $matches[1] -replace '\s',''
		$agentName = $appName "_" + $SystemProfile
		$processEngineString = '[ "w3wp.exe -ap ' + '"' +$processName+'"" ]'
		
	    .\InstallDotNetAgent.ps1 $DTHOME $agentName $CollectorIP -Use64Bit $processEngineString
		
	#}
	
}

















