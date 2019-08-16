########################################
# WS_MGMT_Network_Drive_Mapping        #
# von Patrick Urfer      	       #
# Skript für Workstation Management    #
# Version: 06.08.2019                  #
#                                      #
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

#Pfadangaben hier werden die bestehenden Netzlaufwerkpfade definiert, oder welche es in Zukunft sein sollen dafür kopieren Variabel umbenennen und Pfad angeben
$NetworkPath1 = "K:\Beispiel"
$NetworkPath2 = "L:\Beispiel"

#NetworkPath1 Überprüfungs vorgang für das 1te Laufwerk, für neue Laufwerke kopieren und einzelne Variabeln anpassen

#mapping überprüfung
If (Test-Path -Path $NetworkPath1) {
	Add-Type -AssemblyName System.Windows.Forms 
	$global:balloon = New-Object System.Windows.Forms.NotifyIcon
	$path = (Get-Process -id $pid).Path
	$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
	$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
	$balloon.BalloonTipText = 'Netzlaufwerk existiert bereit'
	$balloon.BalloonTipTitle = "Netzlaufwerk Mapping" 
	$balloon.Visible = $true 
	$balloon.ShowBalloonTip(5000)
	Write-Log -Message 'WS_MGMT_Network_Drive_Mapping: Netzlaufwerk existiert bereits' -Severity Information
}
Else{
    #map Netzlaufwerk, für neue Laufwerke kopieren und Pfad anpassen
    (New-Object -ComObject WScript.Network).MapNetworkDrive("K:Beispiel","\\192.168.1.1\Beispiel")
	Write-Log -Message 'WS_MGMT_Network_Drive_Mapping: Netzlaufwerk wird verbunden' -Severity Information

    #mapping überprüfung
    If (Test-Path -Path $NetworkPath1) {
		Add-Type -AssemblyName System.Windows.Forms 
		$global:balloon = New-Object System.Windows.Forms.NotifyIcon
		$path = (Get-Process -id $pid).Path
		$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
		$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
		$balloon.BalloonTipText = 'Netzlaufwerk wurde gemappt'
		$balloon.BalloonTipTitle = "Netzlaufwerk Mapping" 
		$balloon.Visible = $true 
		$balloon.ShowBalloonTip(5000)
		Write-Log -Message 'WS_MGMT_Network_Drive_Mapping: Netzlaufwerk wurde gemappt' -Severity Information
    }
    Else{
		#mapping entfernen und neu hinzufügen sowie erneute mapping überprüfung, für neue Laufwerke kopieren und Pfad anpassen
		(New-Object -ComObject WScript.Network).Removenetworkdrive("K:Beispiel","\\192.168.1.1\Beispiel")
		(New-Object -ComObject WScript.Network).MapNetworkDrive("K:Beispiel","\\192.168.1.1\Beispiel")
		Write-Log -Message 'WS_MGMT_Network_Drive_Mapping: Netzlaufwerk wurde geloescht' -Severity Information
		Write-Log -Message 'WS_MGMT_Network_Drive_Mapping: Netzlaufwerk wurde erneut gemappt' -Severity Information
		if(Test-Path -Path $NetworkPath1) {
			Add-Type -AssemblyName System.Windows.Forms 
			$global:balloon = New-Object System.Windows.Forms.NotifyIcon
			$path = (Get-Process -id $pid).Path
			$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
			$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
			$balloon.BalloonTipText = 'Netzlaufwerk wurde gemappt'
			$balloon.BalloonTipTitle = "Netzlaufwerk Mapping" 
			$balloon.Visible = $true 
			$balloon.ShowBalloonTip(5000)
		}
		Else{
			#Falls nach dem Prozess kein Mapping gefunden wurde wird der Kunde informiert das er den IT-Provider Kontaktieren soll
			Add-Type -AssemblyName System.Windows.Forms 
			$global:balloon = New-Object System.Windows.Forms.NotifyIcon
			$path = (Get-Process -id $pid).Path
			$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
			$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
			$balloon.BalloonTipText = 'Melden Sie sich fuer weitere Hilfestellungen bei  Ihrem IT Provider'
			$balloon.BalloonTipTitle = "Netzlaufwerk Mapping Fehler!" 
			$balloon.Visible = $true 
			$balloon.ShowBalloonTip(15000)
			Write-Log -Message 'WS_MGMT_Network_Drive_Mapping: Netzlaufwerk konnte nicht gemappt werden' -Severity Error
		}
    }
}

#NetworkPath2 Überprüfungs vorgang für das 2te Laufwerk, für neue Laufwerke kopieren und einzelne Variabeln anpassen

#mapping überprüfung
If (Test-Path -Path $NetworkPath2) {
    Add-Type -AssemblyName System.Windows.Forms 
	$global:balloon = New-Object System.Windows.Forms.NotifyIcon
	$path = (Get-Process -id $pid).Path
	$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
	$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
	$balloon.BalloonTipText = 'Netzlaufwerk existiert bereit'
	$balloon.BalloonTipTitle = "Netzlaufwerk Mapping" 
	$balloon.Visible = $true 
	$balloon.ShowBalloonTip(5000)
}
Else{
    #map Netzlaufwerk, für neue Laufwerke kopieren und Pfad anpassen
    (New-Object -ComObject WScript.Network).MapNetworkDrive("L:Beispiel","\\192.168.1.1\Beispiel")

    #mapping überprüfung
    If (Test-Path -Path $NetworkPath2) {
        Add-Type -AssemblyName System.Windows.Forms 
		$global:balloon = New-Object System.Windows.Forms.NotifyIcon
		$path = (Get-Process -id $pid).Path
		$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
		$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
		$balloon.BalloonTipText = 'Netzlaufwerk wurde gemappt'
		$balloon.BalloonTipTitle = "Netzlaufwerk Mapping" 
		$balloon.Visible = $true 
		$balloon.ShowBalloonTip(5000)
    }
    Else{
		#mapping entfernen und neu hinzufügen sowie erneute mapping überprüfung, für neue Laufwerke kopieren und Pfad anpassen
		(New-Object -ComObject WScript.Network).Removenetworkdrive("L:Beispiel","\\192.168.1.1\Beispiel")
		(New-Object -ComObject WScript.Network).MapNetworkDrive("L:Beispiel","\\192.168.1.1\Beispiel")
		if(Test-Path -Path $NetworkPath2) {
			Add-Type -AssemblyName System.Windows.Forms 
			$global:balloon = New-Object System.Windows.Forms.NotifyIcon
			$path = (Get-Process -id $pid).Path
			$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
			$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
			$balloon.BalloonTipText = 'Netzlaufwerk wurde gemappt'
			$balloon.BalloonTipTitle = "Netzlaufwerk Mapping" 
			$balloon.Visible = $true 
			$balloon.ShowBalloonTip(5000)
		}
		Else{
			#Falls nach dem Prozess kein Mapping gefunden wurde wird der Kunde informiert das er den IT-Provider Kontaktieren soll
			Add-Type -AssemblyName System.Windows.Forms 
			$global:balloon = New-Object System.Windows.Forms.NotifyIcon
			$path = (Get-Process -id $pid).Path
			$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
			$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
			$balloon.BalloonTipText = 'Melden Sie sich fuer weitere Hilfestellungen bei Ihrem IT Provider'
			$balloon.BalloonTipTitle = "Netzlaufwerk Mapping Fehler!" 
			$balloon.Visible = $true 
			$balloon.ShowBalloonTip(15000)
		}
    }
}
