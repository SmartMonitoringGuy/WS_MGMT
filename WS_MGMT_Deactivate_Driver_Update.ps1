########################################
# WS_MGMT_Deactivate_Driver_Update     #
# von Patrick Urfer      	       #
# Automatisierung von Workstation MGMT #
# Version: 30.07.2019		       #
#               		       #
########################################



#Logging Funktion für PowerShell Skripts
function Write-Log {
     [CmdletBinding()]
     param(
	 #Parameter Message wird definiert als String und darf weder Null noch Leer sein
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [string]$Message,
		 
	 #Parameter Severity wird definiert als String mit einem ValidateSet definiert auf Information, Warning und Error und darf weder Null noch Leer sein
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('Information','Warning','Error')]
         [string]$Severity = 'Information'
     )
 
     #Mittels pscustomobjectwird ein Array erstellt welches die Zeitangaben beinhaltet sowie die Parameter Message und Severity
     [pscustomobject]@{
         Time = (Get-Date -f g)
         Message = $Message
         Severity = $Severity
       #Diese werden mittels Out-File unter C:\Windows\Logs\BeispielLog.txt abgespeichert und für jeden neuen Logeintrag mittels -append erweitert
     } | Out-File "C:\Windows\Logs\WSMGMTLog.txt" -Append
 }
 

$registryPath = "HKLM:\Software\Microsoft\Windows"
$name = "ExcludeWUDriversInQualityUpdate"
$value = "1"
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
Write-Log -Message 'WS_MGMT_Deactivate_Driver_Update: Die Aktualisierung der Treiber mittels WUpdate wurde deaktiviert' -Severity Information
#Der Registrykey ist hier gespeichert: Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\ExcludeWUDriversInQualityUpdate
