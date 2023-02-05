#!/bin/bash

# Variables
APACHE_CONF_FILE="/etc/apache2/sites-available/zabbix.conf"
APACHE_SITE_ENABLED_DIR="/etc/apache2/sites-enabled/"
ZABBIX_DB_NAME="zabbix_db"
ZABBIX_DB_USER="zabbix_jonathan"
ZABBIX_DB_PASSWORD="zabbix_Christine1+"

# Vérifier si LAMP est installé
echo "Vérification de l'installation du serveur LAMP..."
if [ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installation du serveur LAMP en cours..."
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo apt-get install mysql-server -y
    sudo apt-get install php -y
    sudo apt-get install libapache2-mod-php -y
    echo "Serveur LAMP installé avec succès."
else
    echo "Serveur LAMP déjà installé."
fi

# Créer la base de données pour Zabbix
echo "Création de la base de données pour Zabbix..."
sudo mysql -u root << EOF
CREATE DATABASE $ZABBIX_DB_NAME;
CREATE USER '$ZABBIX_DB_USER'@'localhost' IDENTIFIED BY '$ZABBIX_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $ZABBIX_DB_NAME.* TO '$ZABBIX_DB_USER'@'localhost';
EOF
echo "Base de données pour Zabbix créée avec succès."

# Installer Zabbix
echo "Installation de Zabbix..."
sudo apt-get install zabbix-server-mysql zabbix-frontend-php -y
echo "Zabbix installé avec succès."

# Configurer l'hôte virtuel Apache pour Zabbix
echo "Création de l'hôte virtuel Apache pour Zabbix..."
sudo echo "
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/share/zabbix
    ServerName zabbix.example.com
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /usr/share/zabbix>
        Require all granted
        AllowOverride None
    </Directory>
</VirtualHost>" > $APACHE_CONF_FILE
sudo ln -s $APACHE_CONF_FILE $APACHE_SITE_ENABLED_DIR
sudo a2enmod alias
sudo a2enmod dir
sudo a2enmod env
sudo a2enmod mime
sudo a2enmod rewrite
sudo a2ensite zabbix
sudo systemctl restart apache2
echo "Hôte virtuel Apache pour Zabbix créé avec succès."

# Configurer la base de données pour Zabbix
echo "Configuration de la base de données pour Zabbix..."
sudo zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -u $ZABBIX_DB_USER -p$ZABBIX_DB_PASSWORD $ZABBIX_DB_NAME
sudo sed -i "s/# DBPassword=/DBPassword=$ZABBIX_DB_PASSWORD/g" /etc/zabbix/zabbix_server.conf
sudo systemctl restart zabbix-server
echo "Base de données pour Zabbix configurée avec succès."

# Configuration terminée avec succès
echo "Installation et configuration de Zabbix terminées avec succès."

