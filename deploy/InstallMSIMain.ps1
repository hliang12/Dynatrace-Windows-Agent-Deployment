
[CmdletBinding()]
param(

	[Parameter(Mandatory=$True)]
	[string]$DTHOME,
	
	[Parameter(Mandatory=$True)]
	[string]$AGENTVERSON,
	
	[Parameter(Mandatory=$True)]
	[String]$MSISERVER, 
	
	[Parameter(Mandatory=$True)]
	[string]$MSIPATH,  #\Dynatrace Software\Software\Windows\Agents example of typical input, path on the MSISERVER <-  this is assuming its a windows server hostng it may have to change and mount if its a linux server

	[Parameter(Mandatory=$True)]
	[string]$DOMAIN,
	
	[Parameter(Mandatory=$True)]
	[string]$USERNAME,
	
	[Parameter(Mandatory=$True)]
	[string]$PASSWORD
	
	)

Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green


$currentDir = pwd

net use $MSISERVER $PASSWORD /user:$DOMAIN\$USERNAME

$AgentInstallerFilter = "dynatrace-agent-"+$AGENTVERSON

Write-Host "Downloading Dynatrace Agent MSI"

cd $MSISERVER$MSIPATH
$installerLocation = pwd

Get-ChildItem -Path $installerLocation | Where-Object {$_.Name -match $AgentInstallerFilter} | Copy-Item -Destination $currentDir"\$AgentInstallerFilter.msi"

cd $currentDir

Write-Host "Finished Downloading Agent MSI"

Write-Host "About to install Dynatrace MSI" 


Write-Host "Running registry backup task..."
.\registry_backup.bat
Write-Host "Done, if no errors" -ForegroundColor green

Write-Host "Installing Agent MSI in Program Files..."

.\InstallMSI.ps1 $DTHOME $AgentInstallerFilter
Write-Host "Done, if no errors" -ForegroundColor green


Write-Host "Retrieving DTHOME rights"
$acl = (Get-Item $DTHOME).GetAccessControl('Access')

Write-Host "Preparing permission set"
$permission = "IIS_IUSRS","FullControl","ContainerInherit","InheritOnly","Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($rule)

Write-Host "Applying new permissions to DTHOME"
Set-Acl $DTHOME $acl
