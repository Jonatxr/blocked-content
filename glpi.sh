#!/bin/bash

# Variables
GLPI_VERSION=10.0.6
GLPI_DB_NAME=glpi
GLPI_DB_USER=glpi
MYSQL_ROOT_PASSWORD=Securepass123+
GLPI_DB_PASSWORD=Glpi123+
GLPI_VHOST_NAME=127.0.0.1

#add repository php7.4
sudo add-apt-repository ppa:ondrej/php7.4

# Install required packages and php7.4 extensions
sudo apt update
sudo apt -y install apache2
sudo apt -y install mysql-server
sudo apt -y install php7.4
sudo apt-get install -y php7.4-cli php7.4-json php7.4-intl php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath

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

#MYSQL secure installation
sudo mysql -uroot ALTER USER 'root'@'localhost' IDENTIFIED BY 'Securepass123+';

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
sudo a2enconf php7.4-fpm
a2dissite 000-default.conf
systemctl reload apache2.service
a2ensite $GLPI_VHOST_NAME.conf
systemctl reload apache2
echo "Merci de consulter /password/pwd pour les mots de passe"
echo "BDD: $GLPI_DB_NAME - User BDD: $GLPI_DB_USER - Mot de passe BDD: GLPI_DB_PASSWORD - MYSQL ROOT PASSWORD: $MYSQL_ROOT_PASSWORD" > /password/pwd