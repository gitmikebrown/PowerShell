#Untested

$scriptUrl = "https://raw.githubusercontent.com/your-username/toolbox/main/hyperv-toolkit.ps1"
$localPath = "$env:TEMP\hyperv-toolkit.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $localPath
PowerShell -ExecutionPolicy Bypass -File $localPath