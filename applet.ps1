# Téléchargement des applets de commandes VMware
Invoke-WebRequest https://download3.vmware.com/software/vmw-tools/powerclicore/PowerCLI_Core.msi -OutFile PowerCLI_Core.msi

# Installation des applets de commandes VMware
Start-Process -FilePath PowerCLI_Core.msi -ArgumentList '/quiet /norestart' -Wait

# Vérification de l'installation
Get-Module VMware.PowerCLI

# Importation du module des applets de commandes VMware
Import-Module VMware.PowerCLI