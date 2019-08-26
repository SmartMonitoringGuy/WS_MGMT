########################################
# WS_MGMT_Uptime_Script                #
# von Patrick Urfer      	       #
# Automatisierung von Workstation MGMT #
# Version: 06.08.2019		       #
# 				       #
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

#Funktion für das Auslesen der Uptime des Geräts.
Function Get-Uptime{
    #CMDLetBinding für die Parameter übergabe der Abarbeitung
    [CMDLetBinding()]
    Param(
        [String]
	#Mittels Parameter Mandatory, gibt man an das der Paramer pflicht ist
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $ComputerName
    )
    #Definition des Verhaltens bei einem Fehler, Anwendung wird gestoppt
    Begin{
        $ErrorActionPreference = 'Stop'
    }
    #Definition des Prozesses
    Process{
	#Variable OS zieht sich mittels Get-WmiObject die Windows-basierte OS mit dme Parameter ComputerName
	#welcher in die Gleichnameige Variabel gespeichert wird sowie mit der Definition der ErrorAction, hier mit SilentlyContinue
        $OS = Get-WmiObject win32_operatingsystem -ComputerName $ComputerName -ErrorAction SilentlyContinue
	#Überprüfung der Daten des WmiObjects auf die Daten 
        If($OS) {
	    #Es wird eine Hashtable generiert
            $Computer = @{}
	    #Der Eintrag Uptime wird der Hashtable hinzugefügt, welches dem Aktuellen Datum und Zeit entspricht, minus des Datum und Zeit des letzten BootUp
            $Computer.Uptime = [DateTime](Get-Date) - [DateTime]$OS.ConvertToDateTime($OS.LastBootUpTime)
	    #Es wird der Hashtable eintrag ComputerName generiert mit den Daten aus der Variabel ComputerName
            $Computer.ComputerName = $ComputerName
	    #Es wird die Hashtable Computer zurückgegeben
            Return $Computer
        }
    }
}

#In der Variabel Uptimes wird nun mittels Environment Variabel auf den Computernamen und es wird auf die Funktion Get-Uptime zugegriffen und dessen Return-Value Computer
$Uptimes = $env:COMPUTERNAME | Get-Uptime
#Aktuelles Datum in $CurrentDate speichern
$CurrentDate = Get-Date
#Ausgabe für das Monitoring Dashboard
Write-Host ""
Write-Host "Skript wurde zuletzt am "$CurrentDate" gestartet!"
Write-Log -Message 'WS_MGMT_Uptime: Skript wurde ausgefuehrt!' -Severity Information
Write-Host ""
#In dem ForEach Loop wird nun für jede Uptime in mehreren Uptimes
ForEach($Uptime in $Uptimes){
	If($Uptime.Uptime.Days -ge "28") {
		Add-Type -AssemblyName System.Windows.Forms			
		$msgBoxInput =  [System.Windows.Forms.MessageBox]::Show('Bitte Neustart durchfuehren, Ihr Geraet wurde bereits mehr als 28 Tage nicht neu gestartet!','Neustart durchfuehren',4,'Error')
		if ($msgBoxInput -eq 'YES'){
			Write-Host ""
			Write-Host "Der Benutzer hat im Neustart Dialog, ausgewaehlt das der Neustart durchgefuehrt wird"
			Write-Log -Message 'WS_MGMT_Uptime: Der Benutzer hat im Neustart Dialog, ausgewaehlt das der Neustart durchgefuehrt wird' -Severity Information
			Write-Host ""
			$msgBoxInputConfirmation =  [System.Windows.Forms.MessageBox]::Show('Bestaetigung Neustart, Sind Sie sicher das der Neustart durchgefuehrt werden soll?','Neustart durchfuehren',4,'Warning')
			if ($msgBoxInputConfirmation -eq 'YES') {
				Write-Host ""
				Write-Host "Der Benutzer hat im Bestaetigungs Dialog fuer den Neustart, ausgewaehlt das der Neustart durchgefuehrt wird"
				Write-Log -Message 'WS_MGMT_Uptime: Der Benutzer hat im Bestaetigungs Dialog fuer den Neustart, ausgewaehlt das der Neustart durchgefuehrt wird' -Severity Information
				Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
				Write-Host ""
				$msgBoxInput = [System.Windows.Forms.DialogResult]::Cancel
				##Neustart erfolgt sofort
				Restart-Computer -Force
				}
			Else {
				Write-Host ""
				Write-Host "Der Benutzer hat im im Bestaetigungs Dialog fuer den Neustart, ausgewaehlt das der Neustart abgebrochen wird"
				Write-Log -Message 'WS_MGMT_Uptime: Der Benutzer hat im im Bestaetigungs Dialog fuer den Neustart, ausgewaehlt das der Neustart abgebrochen wird' -Severity Warning
				Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
				Write-Host ""
				##Neustart wird  abgebrochen
				$msgBoxInputConfirmation = [System.Windows.Forms.DialogResult]::Cancel
				exit 0
				}
		}
		Else {
			Write-Host ""
			Write-Host "Der Benutzer hat im Neustart Dialog, ausgewaehlt das der Neustart abgebrochen wird"
			Write-Log -Message 'WS_MGMT_Uptime: Der Benutzer hat im Neustart Dialog, ausgewaehlt das der Neustart abgebrochen wird' -Severity Warning
			Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
			Write-Host ""
			##Neustart wird  abgebrochen
			$msgBoxInput = [System.Windows.Forms.DialogResult]::Cancel
			exit 0
		}	
	}
	If($Uptime.Uptime.Days -ge "14") {
		#Deaktivieren von Windows 10 Fastboot mittels PowerShell
		#/v is das REG_DWORD /t Spezifiziert den Typ des Registry-Eintrags /d Spezifiziert die Daten für den neuen Eintrag /f Fügt oder löscht den Registry Eintrag hinzu ohne Bestätigung.
		REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "0" /f
		Write-Host ""
		Write-Host "Der Fastboot-Modus wurde mittels Registry Eintrag disabled"
		Write-Log -Message 'WS_MGMT_Uptime: Der Fastboot-Modus wurde mittels Registry Eintrag disabled: ' -Severity Information
		Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
		Write-Host ""
		exit 0
	}
    If($Uptime.Uptime.Days -ge "7") {
        Add-Type -AssemblyName System.Windows.Forms 
		$global:balloon = New-Object System.Windows.Forms.NotifyIcon
		$path = (Get-Process -id $pid).Path
		$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
		$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
		$balloon.BalloonTipText = 'Bitte System Neustart durchfuehren!'
		$balloon.BalloonTipTitle = "Warnung Neustart durchfuehren" 
		$balloon.Visible = $true 
		$balloon.ShowBalloonTip(15000)
		#Benachrichtigung für das Dashboard, für welches Laufwerk der Kunde informiert wurde
		Write-Host ""
		Write-Host "Der Kunde wurde informiert bezueglich der Uptime: "$Uptime.Uptime.Days
		Write-Log -Message 'WS_MGMT_Uptime: Der Kunde wurde informiert bezueglich der Uptime' -Severity Information
		Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
		Write-Host ""
		exit 0
	}	
}	
