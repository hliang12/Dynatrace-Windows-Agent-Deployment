Write-Host "-------------------------------------------------------" -ForegroundColor green
Write-Host "--              Dynatrace LLC                        --" -ForegroundColor green
Write-Host "--              Nicolas Vailliet                     --" -ForegroundColor green
Write-Host "--  Removes Dynatrace .NET agents from app pools     --" -ForegroundColor green
Write-Host "-------------------------------------------------------" -ForegroundColor green

Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green

#$confirm = Read-Host -Prompt "Warning! Are you sure to remove .NET agent injection on all application pools and reset IIS ? (Y/n)"
#if (!$confirm.StartsWith("Y") -and !$confirm.StartsWith("y"))
#{
#	Write-Host "No change has been performed" -ForegroundColor red
#	exit 1
#}

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition  ### fix for using BL

$modulePath = $scriptPath.TrimEnd('y','o','l','p','e','d')

Import-Module "$modulePath/modules/Util.psm1" 
Import-Module "$modulePath/modules/InstallDotNETAgent.psm1" 
Import-Module "$modulePath/modules/InstallWebserverAgent.psm1"

Write-Host "Removing Application Pool agent injection in registry"
# Delete white list and reset environment variables
Disable-DotNETAgent  
Write-Host "Done, if no error" -ForegroundColor green

#IIS reset to apply the changes in IIS sites and app pools
iisreset

Write-Host "Check if application pools are instrumented. If still, restart operating system" -ForegroundColor red