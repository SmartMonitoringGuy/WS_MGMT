########################################
# WS MGMT Deactivate Driver Update     #
# von Patrick Urfer      			   #
# Automatisierung von Workstation MGMT #
# Version: 30.07.2019				   #
#               					   #
########################################

$registryPath = "HKLM:\Software\Microsoft\Windows"
$name = "ExcludeWUDriversInQualityUpdate"
$value = "1"
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
#Geschrieben von Patrick Urfer am 18.06.2019 funktioniert wie geplant, der Registrykey ist hier gespeichert: Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\ExcludeWUDriversInQualityUpdate