# Variables
APACHE_CONF_FILE="/etc/apache2/sites-available/zabbix.conf"
APACHE_SITE_ENABLED_DIR="/etc/apache2/sites-enabled"
ZABBIX_DB_NAME="zabbix"
ZABBIX_DB_USER="zabbix_jonathan"
ZABBIX_DB_PASSWORD="zabbix_Christine1+"
SERVER_NAME="zabbix.sio.local"
DB_NAME="zabbix_db"
DB_USER="zabbix_jonathan"
DB_PASS="Christine1+"

# Vérifier si LAMP est installé
echo "Vérification de l'installation de LAMP..."
if ! dpkg -s apache2 mysql-server php | grep -q 'Status: install ok installed'; then
  echo "LAMP n'est pas installé, installation en cours..."
  sudo apt update
  sudo apt install apache2 mysql-server php -y
  sudo mysql_secure_installation
else
  echo "LAMP est déjà installé."
fi

# Créer l'hôte virtuel Apache pour Zabbix
echo "Création de l'hôte virtuel Apache pour Zabbix..."
sudo bash -c "cat > $APACHE_CONF_FILE <<EOF
<VirtualHost *:80>
  ServerName $SERVER_NAME
  DocumentRoot /usr/share/zabbix
  <Directory /usr/share/zabbix>
    Require all granted
    AllowOverride all
  </Directory>
</VirtualHost>
EOF"
sudo ln -s $APACHE_CONF_FILE $APACHE_SITE_ENABLED_DIR/
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/max_input_time = 60/max_input_time = 300/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/;date.timezone =/date.timezone = Europe\/Paris/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php/7.4/apache2/php.ini
sudo a2enmod mime
sudo a2enmod rewrite
sudo a2ensite zabbix
sudo systemctl restart apache2
echo "Hôte virtuel Apache pour Zabbix créé avec succès."

# Configurer la base de données pour Zabbix
echo "Configuration de MySQL..."
sudo mysql -u root << EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Base de données pour Zabbix Server créée avec succès."

# Mettre à jour les packages et installer Zabbix
echo "Mise à jour des packages et installation de Zabbix..."
sudo apt update
sudo apt install zabbix-server-mysql zabbix-frontend-php -y

# Configurer Zabbix pour utiliser PHP
echo "Configuration de Zabbix pour utiliser PHP..."
sudo sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Paris/' /etc/zabbix/apache.conf
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/7.4/apache2/conf.d/zabbix.ini
sudo sed -i 's/max_input_time = 60/max_input.time = 300/' /etc/php/7.4/apache2/conf.d/zabbix.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php/7.4/apache2/conf.d/zabbix.ini

# Redémarrer Apache
echo "Redémarrage d'Apache pour prendre en compte les modifications..."
sudo systemctl restart apache2

echo "Installation de Zabbix terminée avec succès."