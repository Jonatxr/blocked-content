#!/bin/bash

# Variables
GLPI_VERSION=10.0.6
GLPI_DB_NAME=glpidb
GLPI_DB_USER=glpiuser
MYSQL_ROOT_PASSWORD=Christine1+
GLPI_DB_PASSWORD=password
GLPI_VHOST_NAME=glpi.sio.local

# Install required packages and PHP extensions
apt-get update
apt-get install -y apache2 mariadb-server php libapache2-mod-php php-mysql php-curl php-fileinfo php-gd php-json php-mbstring php-mysqli php-session php-zlib php-simplexml php-xml php-intl

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
mv glpi /var/www/
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
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $GLPI_DB_NAME.* TO '$GLPI_DB_USER'@'localhost';"

if [ -d "/var/www/glpi" ]; then
	a2dissite $GLPI_VHOST_NAME
    rm -rf /etc/apache2/sites-available/$GLPI_VHOST_NAME.conf
fi

# Create Apache virtual host
echo "<VirtualHost *:80>
        ServerName $GLPI_VHOST_NAME
        DocumentRoot /var/www/glpi
        <Directory /var/www/glpi>
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$GLPI_VHOST_NAME.conf
a2ensite $GLPI_VHOST_NAME.conf
systemctl restart apache2
