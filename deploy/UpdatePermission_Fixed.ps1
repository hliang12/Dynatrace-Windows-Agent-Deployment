
Write-Host "-----------------------------------------------------------------" -ForegroundColor green
Write-Host "--              Dynatrace LLC                                  --" -ForegroundColor green
Write-Host "--              Nicolas Vailliet                               --" -ForegroundColor green
Write-Host "--  			Fix Permissions									--" -ForegroundColor green
Write-Host "-----------------------------------------------------------------" -ForegroundColor green

Write-Host "Set-ExecutionPolicy..."
# Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy "RemoteSigned" -Scope Process -Confirm:$false
Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false
Write-Host "Ready to run the script if no error." -ForegroundColor green

Write-Host "Install dir is C:\Program Files (x86)\dynaTrace\Dynatrace Agent 6.3"
Set-Variable -Name "DTHOME" -Value "C:\Program Files (x86)\dynaTrace\Dynatrace Agent 6.3"

Write-Host "Retrieving DTHOME rights"
$acl = (Get-Item $DTHOME).GetAccessControl('Access')

Write-Host "Preparing permission set"
$permission = "IIS_IUSRS","FullControl","ContainerInherit","InheritOnly","Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($rule)

Write-Host "Applying new permissions to DTHOME"
Set-Acl $DTHOME $acl

Stop-Service -displayname "Dynatrace Webserver Agent"
Start-Service -displayname "Dynatrace Webserver Agent"

iisreset

Write-Host "Done, if no errors" -ForegroundColor green
