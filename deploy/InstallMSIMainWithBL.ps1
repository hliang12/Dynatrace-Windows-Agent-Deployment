<#
.SYNOPSIS
    Extracts files from an MSI-installer without executing the installer.
	Used with BladeLogic with the assumption that the installer has been moved to the server using BladeLogic
.DESCRIPTION
    Doesn't extract files if targetfolder already exists. Wait's until all files are extracted.
	
.PARAMETER DTHOME
    Dynatrace installation location

#>
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


###GET MSI NAME

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Write-Host = $scriptPath "script path" 

$InstallerName = Get-ChildItem $scriptPath\*.msi -name
		
Write-Host = $InstallerName "Installer name"

Write-Host = "Execution Path of the script is : " $scriptPath
		

$FilePathRegBat = $scriptPath + '\registry_backup.bat'
$FilePathMSIInstaller = $scriptPath + '\InstallMSI.ps1'

Write-Host $FilePathRegBat
Write-Host $FilePathMSIInstaller
Write-Host "About to install Dynatrace MSI" 

Write-Host "Running registry backup task..."
#.\registry_backup.bat
& $FilePathRegBat
Write-Host "Done, if no errors" -ForegroundColor green

Write-Host "Installing Agent MSI in Program Files..."

$fullPathtoMSI = $scriptPath+'\'+$InstallerName

#.\InstallMSI.ps1 $DTHOME $InstallerName
& $FilePathMSIInstaller $DTHOME $fullPathtoMSI 
Write-Host "Done, if no errors" -ForegroundColor green


Write-Host "Retrieving DTHOME rights"
$acl = (Get-Item $DTHOME).GetAccessControl('Access')

Write-Host "Preparing permission set"
$permission = "IIS_IUSRS","FullControl","ContainerInherit","InheritOnly","Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($rule)

Write-Host "Applying new permissions to DTHOME"
Set-Acl $DTHOME $acl
