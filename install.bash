#!/bin/bash

# Mise à jour du système
sudo apt-get update
sudo apt-get upgrade -y

# Installation d'Apache
sudo apt-get install apache2 -y

# Installation de PHP
sudo apt-get install php libapache2-mod-php php-mysql php-gd php-imap php-ldap php-mbstring php-xml php-xmlrpc -y

# Installation de MySQL
sudo apt-get install mysql-server -y

# Installation de certaines dépendances de GLPI
sudo apt-get install graphviz -y

# Redémarrage d'Apache pour prendre en compte PHP
sudo service apache2 restart