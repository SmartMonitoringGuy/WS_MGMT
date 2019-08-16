########################################
# WS_MGMT_Empty_RecycleBin_&_TEMP 	   #
# von Patrick Urfer      			   #
# Automatisierung von Workstation MGMT #
# Version: 30.07.2019				   #
# 						   			   #
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
 
 
#Hier wird der Pfad bestimmt für das Löschen der Temporären Dateien, TempFileLocation wird mittels Environment Variable Env definiert
$TempFileLocation = "$env:windir\Temp","$env:TEMP"
#Hier definieren wir den Pfad für das Löschen der Dateien für die Updates, welche nachdem Updatevorgang nicht mehr benötigt werden
$UpdateFileLocation = "$env:windir\SoftwareDistribution\Download"

#Hier werden die Tempfiles mittels Get-ChildItem Funktion eingelesen, Recurse bewirkt das es für alle Files durchgeführt wird, Mittels .AddDays werden 7 Tage abgezogen vom aktuellen Datum
$TempFile = Get-ChildItem $TempFileLocation -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
$TempFileCount = ($TempFile).count
#In der IF Überprüfung wird geprüft ob die Anzahl Tempfiles 0 ist, falls dies der Fall ist wird eine Nachricht ausgegeben das keine Tempfiles vorhanden sind
if($TempFileCount -eq "0" -or $TempFileCount -eq $null) { 
	Write-Host "Keine Temporaerendaten in der Ablage $TempFileLocation" -ForegroundColor Green
	Write-Log -Message 'WS_MGMT_Empty_RecycleBin_&_TEMP: Keine Temoraerendaten in der Ablage' -Severity Information
}
#Im Else Teil der Überprüfung wird für das Tempfile der Löschvorgang initiert ohne bestätigung und mittels Recurse für alle Tempfiles durchgeführt
Else {
	$TempFile | Remove-Item -Confirm:$false -Recurse -Force -Verbose -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
	Write-Host "Es wurden $TempFileCount Dateien im Ordner $TempFileLocation geloescht" -ForegroundColor Green
	Write-Log -Message 'WS_MGMT_Empty_RecycleBin_&_TEMP: Es wurden Temporaere Dateien geloescht' -Severity Information
}

#Hier werden die UpdateFile mittels Get-ChildItem Funktion eingelesen, Recurse bewirkt das es für alle Files durchgeführt wird, Mittels .AddDays werden 7 Tage abgezogen vom aktuellen Datum
$UpdateFile = Get-ChildItem $UpdateFileLocation -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
$UpdateFileCount = ($UpdateFile).Count
#In der IF Überprüfung wird geprüft ob die Anzahl Updatefiles 0 ist, falls dies der Fall ist wird eine Nachricht ausgegeben das keine Updatefiles vorhanden sind
if($UpdateFileCount -eq "0" -or $UpdateFileCount -eq $null){
	Write-Host "Keine Dateien im Ordner $UpdateFileLocation" -ForegroundColor Green
	Write-Log -Message 'WS_MGMT_Empty_RecycleBin_&_TEMP: Keine UpdateDateien in der Ablage' -Severity Information
}
#Im Else Teil der Überprüfung wird für das Updatefile der Löschvorgang initiert ohne bestätigung und mittels Recurse wird es für alle Updatefiles durchgeführt
Else {
	$UpdateFile | Remove-Item -Confirm:$false -Recurse -Force -Verbose -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
	Write-Host "Es wurden $UpdateFileCount Dateien im Ordner $UpdateFileLocation geloescht" -ForegroundColor Green
	Write-Log -Message 'WS_MGMT_Empty_RecycleBin_&_TEMP: Es wurden UpdateDateien geloescht' -Severity Information
}

#Anschliesssend im ForEach Code Segment wird mittels Get-PSDrive das Laufwerk eingelesen und der Variabel $Drive hinzugefügt
ForEach ($Drive in Get-PSDrive -PSProvider FileSystem) {
	#In PathBin wird der Pfad für den Papierkorb definiert
    $BinPath = $Drive.Name + ':\$Recycle.Bin'
	#In diesem Codesegment wird mittels Get-ChildItem die Dateien im Papierkorb eingelesen und mittels Recurse für alle Dateien durchgeführt,  Mittels .AddDays werden 7 Tage abgezogen vom aktuellen Datum
	$Bin = Get-ChildItem $BinPath -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
	$BinCount = ($Bin).count
	#Im If Teil wird überprüft ob die anzahl Files im Papierkorb 0 ist, falls dies der Fall ist wird eine Nachricht ausgegeben das keine Files vorhanden sind
	if($BinCount -eq "0" -or $BinCount -eq $null) {
		Write-Host "Es wurden keine zu loeschenden Temporaeren Dateien in $BinPath gefunden" -ForegroundColor Green
		Write-Log -Message 'WS_MGMT_Empty_RecycleBin_&_TEMP: Keine Dateien im Papierkorb' -Severity Information
	}
	#Im Else Teil der Überprüfung wird für die Files im Papierkorb der Löschvorgang initiert ohne bestätigung und mittels Recurse wird es für alle Files durchgeführt
	Else {
		$Bin | Remove-Item -Force -Recurse -Verbose -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
		Write-Host "Es wurden $BinCount Dateien im Ordner $BinPath geloescht" -ForegroundColor Green
		Write-Log -Message 'WS_MGMT_Empty_RecycleBin_&_TEMP: Papierkorb wurde geleert' -Severity Information
	}
}