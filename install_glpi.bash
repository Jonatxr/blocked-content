#!/bin/bash

# Variables
GLPI_VERSION="9.5.2"
GLPI_DIRECTORY="/var/www/html/glpi"
GLPI_DB_NAME="glpi"
GLPI_DB_USER="glpi"
GLPI_DB_PASSWORD="glpi"
APACHE_VHOST_NAME="glpi.example.com"

# Mise à jour du système
sudo apt-get update
sudo apt-get upgrade -y

# Installation des paquets nécessaires
sudo apt-get install -y apache2 php php-mysql php-intl php-curl libapache2-mod-php mysql-server

# Téléchargement de la dernière version de GLPI
wget https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz

# Extraction des fichiers de GLPI
tar -xvzf glpi-$GLPI_VERSION.tgz

# Déplacement des fichiers de GLPI dans le répertoire web d'Apache
sudo mv glpi $GLPI_DIRECTORY

# Configuration des droits d'accès pour le répertoire de GLPI
sudo chown -R www-data:www-data $GLPI_DIRECTORY
sudo chmod -R 775 $GLPI_DIRECTORY/files

# Configuration de MySQL pour permettre les connexions à distance
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

# Création de l'utilisateur et de la base de données GLPI
mysql -u root -p <<EOF
CREATE USER '$GLPI_DB_USER'@'%' IDENTIFIED BY '$GLPI_DB_PASSWORD';
CREATE DATABASE $GLPI_DB_NAME;
GRANT ALL PRIVILEGES ON $GLPI_DB_NAME.* TO '$GLPI_DB_USER'@'%';
EOF

# Création de l'hôte virtuel Apache pour GLPI
sudo echo "<VirtualHost *:80>
  ServerAdmin admin@example.com
  DocumentRoot $GLPI_DIRECTORY
  ServerName $APACHE_VHOST_NAME
  ServerAlias www.$APACHE_VHOST_NAME

  <Directory $GLPI_DIRECTORY>
    Options FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>

  ErrorLog /var/log/apache2/glpi-error.log
  CustomLog /var/log/apache2/glpi-access.log combined
</VirtualHost>" >> /etc/apache2/sites-available/glpi.conf

# Activation de l'hôte virtuel Apache pour GLPI
sudo a2ensite glpi

#Redémarrage d'Apache pour prendre en compte les modifications

sudo service apache2 restart

#Nettoyage des fichiers temporaires

rm glpi-$GLPI_VERSION.tgz

echo "L'installation de GLPI a été terminée avec succès."