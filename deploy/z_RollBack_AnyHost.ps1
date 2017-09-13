Write-Host "-------------------------------------------------------" -ForegroundColor green
Write-Host "--              Dynatrace LLC                        --" -ForegroundColor green
Write-Host "--              Nicolas Vailliet                     --" -ForegroundColor green
Write-Host "--  Removes Dynatrace .NET and IIS agent on a host   --" -ForegroundColor green
Write-Host "-------------------------------------------------------" -ForegroundColor green

Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green


#$confirm = Read-Host -Prompt "Warning! Are you sure to remove all Dynatrace-related configuration and installation files and reset IIS ? (Y/n)"
#if (!$confirm.StartsWith("Y") -and !$confirm.StartsWith("y"))
#{
#	Write-Host "No change has been performed" -ForegroundColor red
#	exit 1
#}

Import-Module "../modules/Util" 
Import-Module "../modules/InstallDotNETAgent" 
Import-Module "../modules/InstallWebserverAgent"

Write-Host "Stopping Web Server Agent service..."
Stop-Service -displayname "Dynatrace Webserver Agent"
Write-Host "Done, if no error" -ForegroundColor green

Write-Host "Removing Application Pool agent injection in registry"
# Delete white list and reset environment variables
Disable-DotNETAgent  
Write-Host "Done, if no error" -ForegroundColor green

Write-Host "Removing DT Modules from IIS"
#Removes 64b version
Uninstall-WebserverAgentModule($true)
#Removes 32b version
Uninstall-WebserverAgentModule($false)
Write-Host "Done, if no error" -ForegroundColor green

Write-Host "Uninstalling DT WS Agent service"
# Stops and delete DT WS Agent service
Uninstall-WebserverAgentService
Write-Host "Done, if no error" -ForegroundColor green

#Delete Service if still there
sc.exe delete "Dynatrace Webserver Agent"

#IIS reset to apply the changes in IIS sites and app pools
iisreset

Write-Host "Deleting installation directory"
# Remove install dir in Program Files
Remove-Item -Recurse -Force 'C:\Program Files (x86)\Dynatrace'    #### need to check this 
Write-Host "Done, if no error" -ForegroundColor green

Write-Host "Check if application pools are instrumented. If still, restart operating system" -ForegroundColor red