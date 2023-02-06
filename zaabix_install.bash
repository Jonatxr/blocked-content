#!/bin/bash

# Variables
DB_NAME=zabbix_database
DB_USER=zabbix_admin
DB_PASS=Christine1+
DB_HOST=localhost

# Update system and install packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 php php-mysql libapache2-mod-php mysql-server zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Install zabbix
wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu20.04_all.deb
dpkg -i zabbix-release_6.2-4+ubuntu20.04_all.deb
sudo apt update

# Configure PHP
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/max_input_time = 60/max_input_time = 300/g' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/;date.timezone =/date.timezone = Europe\/Paris/g' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php/7.4/apache2/php.ini

# Restart Apache
sudo systemctl restart apache2

# Create database and user
mysql -u root << EOF
CREATE DATABASE $DB_NAME CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';
FLUSH PRIVILEGES;
set global log_bin_trust_function_creators = 1;
EOF

# Import Zabbix database schema
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u $DB_USER -p$DB_PASS $DB_NAME

# Configure Zabbix server
sudo sed -i "s/# DBPassword=.*/DBPassword=$DB_PASS/g" /etc/zabbix/zabbix_server.conf

# Start Zabbix server
sudo systemctl restart zabbix-server

# Configure Apache virtual host
sudo bash -c "cat << EOF > /etc/apache2/sites-available/zabbix.conf
<VirtualHost *:80>
  ServerName zabbix.sio.local
  DocumentRoot /usr/share/zabbix
  <Directory /usr/share/zabbix>
    Require all granted
  </Directory>
</VirtualHost>
EOF"
sudo a2ensite zabbix
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
systemctl enable zabbix-server zabbix-agent apache2