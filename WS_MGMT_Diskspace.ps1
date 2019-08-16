#Variabel Disks zieht das WmiObject Win32_LogicalDisk für die Informationen der jeweiligen Festplatten
$Disks = Get-WmiObject -Class Win32_LogicalDisk
#Aktuelles Datum in $CurrentDate speichern
$CurrentDate = Get-Date
#Ausgabe für das Monitoring Dashboard
Write-Host ""
Write-Host "Skript wurde zuletzt am "$CurrentDate" ausgefuehrt!"
Write-Host ""
ForEach($Disk in $Disks) {
	#Der Eintrag DeviceID wird hinzugefügt, welcher den Namen des Drives Speichert
	$DriveName = $Disk.DeviceID
	#Ausgabe für das Monitoring Dashboard
	Write-Host ""
	Write-Host "Das Laufwerk "$DriveName" wird ueberprueft"
	Write-Host ""
	#Der Eintrag FreeSpace wird hinzugefügt, welcher nach der Konvertierung den Freien Speicherplatz Speichert
	[Double]$DriveFreeSpace = ($Disk.FreeSpace/1GB)
	#Ausgabe für das Monitoring Dashboard
	Write-Host ""
	Write-Host "Die Menge an Freier Speicherkapazitaet betraegt: "$DriveFreeSpace"GB"
	Write-Host ""
	#Der Eintrag Size wird hinzugefügt, welcher nach der Konvertierung den gesamten Speicherplatz Speichert
	[Double]$DriveSize = ($Disk.Size/1GB)
	#Ausgabe für das Monitoring Dashboard
	Write-Host ""
	Write-Host "Die Speicherkapazitaet des Drives betraegt: "$DriveSize"GB"
	Write-Host ""
	#Der Eintrag Used wird hinzugefügt, welcher nach der Konvertierung den verwendeten Speicherplatz in % Speicher
	[Double]$DriveUsed = ($DriveFreeSpace/$DriveSize*100)
	#Ausgabe für das Monitoring Dashboard
	Write-Host ""
	Write-Host "Der Verwendete Speicher betraegt: "$DriveUsed"%"
	Write-Host ""
	
	#Mittels If-Prüfung wird der Freie Speicherplatz sowie der Benutzte Speicherplatz auf jeweils 15GB oder 15% Speichervolumen überprüft
	If($DriveFreeSpace -lt 15 -or $DriveUsed -lt 15) {
		#Nach der Überprüfung wird mittels Bubbleelement eine Mitteilung an den Benutzer verfasst
		Add-Type -AssemblyName System.Windows.Forms
		$global:balloon = New-Object System.Windows.Forms.NotifyIcon
		$path = (Get-Process -id $pid).Path
		$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
		$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
		$balloon.BalloonTipText = 'Ihr Speicher auf laeuft voll, bitte loeschen Sie nicht benoetigte Daten oder melden Sie sich Telefonisch bei Ihrem IT-Provider'
		$balloon.BalloonTipTitle = "Speicherwarnung Festplatte "
		$balloon.Visible = $true 
		#Die Benachrichtigung bleibt 15 Sekunden eingeblendet
		$balloon.ShowBalloonTip(15000)
		#Benachrichtigung für das Dashboard, für welches Laufwerk der Kunde informiert wurde
		Write-Host ""
		Write-Host "Der Kunde wurde informiert bezueglich dem Laufwerk: "$DriveName
		Write-Host ""
	}
}