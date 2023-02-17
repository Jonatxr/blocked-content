#!/bin/bash

# Variables
GLPI_VERSION=10.0.6
GLPI_DB_NAME=glpidb
GLPI_DB_USER=glpiuser
MYSQL_ROOT_PASSWORD=jerrom123+
GLPI_DB_PASSWORD=password
GLPI_VHOST_NAME=127.0.0.1

#add repository php
sudo add-apt-repository ppa:ondrej/php

# Install required packages and PHP extensions
sudo apt update
sudo apt install apache2 mysql-server php7.4 php7.4-fpm libapache2-mod-php7.4 php-mysql7.4 php-curl7.4 php-fileinfo7.4 php-gd7.4 php-json7.4 php-mbstring7.4 php-mysqli7.4 php-session7.4 php-zlib7.4 php-simplexml7.4 php-xml7.4 php-intl7.4

#Create working repo
mkdir /tempglpi
cd /tempglpi

# Delete GLPI if already exists
if [ -d "/var/www/html/glpi" ]; then
    rm -rf /var/www/html/glpi
fi
if [ -d "/var/www/glpi" ]; then
    rm -rf /var/www/glpi
fi

# Download GLPI
wget https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz
tar xvfz glpi-$GLPI_VERSION.tgz
mv glpi /var/www/glpi
chown -R www-data:www-data /var/www/glpi

# Delete existing database and user if they exist
if mysql -u root -p$MYSQL_ROOT_PASSWORD -e "use $GLPI_DB_NAME"; then
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE $GLPI_DB_NAME;"
fi
if mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT User FROM mysql.user WHERE User='$GLPI_DB_USER'" | grep $GLPI_DB_USER; then
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DROP USER $GLPI_DB_USER@localhost;"
fi

# Create GLPI database and user
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $GLPI_DB_NAME;"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$GLPI_DB_USER'@'localhost' IDENTIFIED BY '$GLPI_DB_PASSWORD';"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$GLPI_DB_USER'@'localhost';"

if [ -d "/var/www/glpi" ]; then
	a2dissite $GLPI_VHOST_NAME
    rm -rf /etc/apache2/sites-available/$GLPI_VHOST_NAME.conf
fi

# Create Apache virtual host
echo "<VirtualHost *:80>
        DocumentRoot /var/www/glpi
         <Directory /var/www/glpi>
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$GLPI_VHOST_NAME.conf
wget https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi10.0.6%2B1.1/fusioninventory-10.0.6+1.1.tar.bz2
tar xvf fusioninventory-10.0.6+1.1.tar.bz2
mv fusioninventory /var/www/glpi/plugins/
a2dissite 000-default.conf
systemctl reload apache2.service
a2ensite $GLPI_VHOST_NAME.conf
systemctl reload apache2