# Variables pour la configuration de la VM
$VMName = "UbuntuServer20.04"
$ESXIHost = "192.168.1.128"
$Datastore = "datastore1"
$DiskSize = "12GB"
$NumCpu = 2
$Memory = 4GB
$Network = "VLAN 20"
$Username = "root"
$ISO = "[datastore1] ISO/ubuntu-20.04.5-live-server-amd64 (1).iso"

# Vérification et modification des paramètres d'exécution de scripts si nécessaire
if (!(Get-ExecutionPolicy -Scope Process -ErrorAction SilentlyContinue) -eq "Unrestricted")
{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Confirm:$false
}

# Connexion au serveur ESXi
Connect-VIServer $ESXIHost

# Création de la machine virtuelle
New-VM -Name $VMName -Datastore $Datastore -DiskStorageFormat Thin -OS Linux -Version Ubuntu_64 -MemoryGB $Memory -NumCpu $NumCpu -DiskGB $DiskSize

# Configuration de la carte réseau
Get-VM $VMName | New-NetworkAdapter -NetworkName $Network

# Configuration du boot en CD/DVD
Get-CDDrive | Set-CDDrive -IsoPath $ISO -StartConnected:$true -Confirm:$false

# Configuration du nom d'utilisateur
Get-VM $VMName | New-AdvancedSetting -Name "UserName" -Value "$Username"

# Démarrage de la machine virtuelle
Start-VM -VM $VMName