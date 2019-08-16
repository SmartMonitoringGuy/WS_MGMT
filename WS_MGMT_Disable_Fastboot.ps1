########################################
# WS_MGMT_Disable_Fastboot             #
# von Patrick Urfer      			   #
# Automatisierung von Workstation MGMT #
# Version: 30.07.2019				   #
# 					                   #
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
 
 
#Aktuelles Datum in $CurrentDate speichern
$CurrentDate = Get-Date
#Ausgabe für das Monitoring Dashboard
Write-Host ""
Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
Write-Host ""
#Deaktivieren von Windows 10 Fastboot mittels PowerShell
#/v is das REG_DWORD /t Spezifiziert den Typ des Registry-Eintrags /d Spezifiziert die Daten für den neuen Eintrag /f Fügt oder löscht den Registry Eintrag hinzu ohne Bestätigung.
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "0" /f
Write-Host ""
Write-Host "Der Fastboot-Modus wurde mittels neuem Registry Eintrag disabled"
Write-Log -Message 'WS_MGMT_Disable_Fastboot: Der Fastboot-Modus wurde mittels Registry Eintrag disabled: ' -Severity Warning
Write-Host ""
