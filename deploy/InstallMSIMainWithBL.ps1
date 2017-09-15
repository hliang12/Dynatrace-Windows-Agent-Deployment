
[CmdletBinding()]
param(

	[Parameter(Mandatory=$True)]
	[string]$DTHOME
	
	)

Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green

$InstallerName = Get-ChildItem *.msi -name

###GET MSI NAME

Write-Host "About to install Dynatrace MSI" 

Write-Host "Running registry backup task..."
.\registry_backup.bat
Write-Host "Done, if no errors" -ForegroundColor green

Write-Host "Installing Agent MSI in Program Files..."

.\InstallMSI.ps1 $DTHOME $InstallerName
Write-Host "Done, if no errors" -ForegroundColor green


Write-Host "Retrieving DTHOME rights"
$acl = (Get-Item $DTHOME).GetAccessControl('Access')

Write-Host "Preparing permission set"
$permission = "IIS_IUSRS","FullControl","ContainerInherit","InheritOnly","Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($rule)

Write-Host "Applying new permissions to DTHOME"
Set-Acl $DTHOME $acl
