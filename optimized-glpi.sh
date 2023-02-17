#!/bin/bash

# Variables
GLPI_VERSION=10.0.6
GLPI_DB_NAME=glpi
GLPI_DB_USER=glpi
MYSQL_ROOT_PASSWORD=Securepass123+
GLPI_DB_PASSWORD=Glpi123+
GLPI_VHOST_NAME=127.0.0.1

# Add repository php7.4
sudo add-apt-repository -y ppa:ondrej/php7.4

# Install required packages and php7.4 extensions
sudo apt update && sudo apt -y install apache2 mysql-server php7.4 php7.4-cli php7.4-json php7.4-intl php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath

# Create working repo
mkdir -p /tempglpi && cd /tempglpi

# Delete GLPI if already exists
if [ -d "/var/www/html/glpi" ] || [ -d "/var/www/glpi" ]; then
    sudo rm -rf /var/www/{html/,}glpi
fi

# Download and install GLPI
sudo wget -q "https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz" && sudo tar xzf glpi-$GLPI_VERSION.tgz && sudo mv glpi /var/www/glpi && sudo chown -R www-data:www-data /var/www/glpi

# Delete existing database and user if they exist
if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "use $GLPI_DB_NAME"; then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE $GLPI_DB_NAME;"
fi
if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT User FROM mysql.user WHERE User='$GLPI_DB_USER'" | grep $GLPI_DB_USER; then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER $GLPI_DB_USER@localhost;"
fi

# Secure MYSQL installation and create GLPI database and user
sudo mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Securepass123+'; CREATE DATABASE $GLPI_DB_NAME; CREATE USER '$GLPI_DB_USER'@'localhost' IDENTIFIED BY '$GLPI_DB_PASSWORD'; GRANT ALL PRIVILEGES ON *.* TO '$GLPI_DB_USER'@'localhost';"

# Create Apache virtual host
sudo tee /etc/apache2/sites-available/$GLPI_VHOST_NAME.conf > /dev/null <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/glpi
    <Directory /var/www/glpi>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Install FusionInventory plugin
sudo wget -q "https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi10.0.6%2B1.1/fusioninventory-10.0.6+1.1.tar.bz2" && sudo tar xjf fusioninventory-10.0.6+1.1.tar.bz2 && sudo mv fusioninventory /var/www/glpi/plugins/

# Enable Apache configuration and reload service
sudo a2dissite 000-default.conf && sudo a2enconf php7.4-fpm && sudo a