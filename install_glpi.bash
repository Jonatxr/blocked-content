#!/bin/bash

# Variables
GLPI_VERSION=10.6.3
GLPI_DB_NAME=glpidb
GLPI_DB_USER=glpiuser
GLPI_DB_PASSWORD=password
GLPI_VHOST_NAME=glpi.example.com

# Install required packages and PHP extensions
apt-get update
apt-get install -y apache2 mariadb-server php libapache2-mod-php php-mysql php-curl php-fileinfo php-gd php-json php-mbstring php-mysqli php-session php-zlib php-simplexml php-xml php-intl

# Download GLPI
wget https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz
tar xvfz glpi-$GLPI_VERSION.tgz
mv glpi /var/www/html/
chown -R www-data:www-data /var/www/html/glpi

# Create GLPI database and user
mysql -e "CREATE DATABASE $GLPI_DB_NAME;"
mysql -e "CREATE USER '$GLPI_DB_USER'@'localhost' IDENTIFIED BY '$GLPI_DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $GLPI_DB_NAME.* TO '$GLPI_DB_USER'@'localhost';"

# Create Apache virtual host
echo "<VirtualHost *:80>
        ServerName $GLPI_VHOST_NAME
        DocumentRoot /var/www/html/glpi
        <Directory /var/www/html/glpi>
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$GLPI_VHOST_NAME.conf
a2ensite $GLPI_VHOST_NAME.conf
systemctl reload apache2
