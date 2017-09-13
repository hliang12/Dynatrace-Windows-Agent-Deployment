Function Wait-For ([string]$fileName, [string]$arguments)
{
<#
.SYNOPSIS
   Runs processes, waiting until the exit. 
.PARAMETER filename
    Process to execute
.PARAMETER arguments
    Arguments to be passed to the process.
        
#>
	if ($arguments.Length -gt 0)
	{
		return (Start-Process -FilePath $fileName -ArgumentList $arguments -NoNewWindow -Wait -Passthru).ExitCode
	}
	else
	{
		return (Start-Process -FilePath $fileName -NoNewWindow -Wait -Passthru).ExitCode
	}
}

Function Get-FilesFromMSI([string]$Installer, [string]$InstallPath)
{
<#
.SYNOPSIS
    Extracts files from an MSI-installer without executing the installer.
.DESCRIPTION
    Doesn't extract files if targetfolder already exists. Wait's until all files are extracted.
.PARAMETER Installer
    Installer file
.PARAMETER InstallPath
    Targetfolder 
        
#>
	if (!(Test-Path $InstallPath)) #already installed?
	{
		if (!(Test-Path $Installer)) 
		{
			"Installer not available - installation failed!"
		}
		else
		{
			"Extract Files From Installer..."
			$arg = "/a $Installer /qn TARGETDIR=""$InstallPath"""
			$ret = Wait-For "msiexec" $arg
			if ($ret -gt 0)
			{
				"'msiexec $arg' failed, return code is " + ($ret -as [string])
			}
			"Complete."

			if (Test-Path "$InstallPath\agent\conf\dynaTraceWebServerSharedMemory")
			{
				"Delete 'dynaTraceWebServerSharedMemory'"
				Remove-Item "$InstallPath\agent\conf\dynaTraceWebServerSharedMemory"
			}
		}
	}
    else
    {
        "Skipped extracting files from MSI - targetfolder already exists."
    }
}

Function Test-ServiceInstallation([string]$ServiceName)
{
<#
.SYNOPSIS
    Tests if a specifc windows service is already installed.
.PARAMETER ServiceName
    Name of the service to check.
#>
	$res = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
    return ($res -ne $null)
}

Function Get-DTHOME
{  
<#
.SYNOPSIS
    Auto detect DT version and installation directory 
.DESCRIPTION
    Return False if could not find DTHOME
#>
	#Get latest installed dynatrace agent version directory
	$DTHOME = Get-ChildItem -Path "C:\Program Files (x86)\Dynatrace" -Name -Include "*Dynatrace Agent*" | Select-Object -Last 1

	#Test if any agent is installed on the machine
	If (-Not $DTHOME)
	{
		#setting to false if not detected
		$DTHOME = 0
		return $DTHOME
	}

	#Creating full path to agent
	$DTHOME = "C:\Program Files (x86)\Dynatrace\$DTHOME"
    return $DTHOME  
} 

Function Get-IniContent 
{  
<#
.SYNOPSIS
    Reads key/values of an .ini file into a hash-table. 
.DESCRIPTION
    Only suppoerts key/value entries separated with spaces 
.PARAMETER FilePath
    Filename of the ini-file
#>
    [CmdletBinding()]  
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]  
        [Parameter(ValueFromPipeline=$True,Mandatory=$True)]  
        [string]$FilePath  
    )  
      
    $ini = @{}  
    switch -regex -file $FilePath  
    {  

        "^\s*(\w+)\s*(.*)\s*$" # Key  
        {  
            $name,$value = $matches[1..2]  
            $ini[$name] = $value  
        }  
    }  

    return $ini  
} 


function ConvertTo-Json20([object] $item){
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer
    return $ps_js.Serialize($item)
}

function ConvertFrom-Json20([object] $item){ 
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer

    #The comma operator is the array construction operator in PowerShell
    return ,$ps_js.DeserializeObject($item)
}


Function Update-DTPermissions{  
<#
.SYNOPSIS
    Make sure DTHOME permissions are correctly set up 
.PARAMETER DTHOME
   DTHOME - directory whose permissions will be updated
#>
    [CmdletBinding()]  
    Param(  
        [string]$DTHOME  
    )  
	
	#Write-Host "Retrieving DTHOME rights"
	$acl = (Get-Item $DTHOME).GetAccessControl('Access')

	#Write-Host "Preparing permission set"
	$permission = "IIS_IUSRS","FullControl","ContainerInherit","InheritOnly","Allow"
	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
	$acl.AddAccessRule($rule)

	#Write-Host "Applying new permissions to DTHOME"
	Set-Acl $DTHOME $acl
} 

Function Restart-WebServerAgentISSRESET{  
<#
.SYNOPSIS
    Restart the Dynatrace Web Server agent and perform IIS Reset 
#>
	Stop-Service -displayname "Dynatrace Webserver Agent"
	Start-Service -displayname "Dynatrace Webserver Agent"
	Wait-For "iisreset"
	iex "net start w3svc"
} 
