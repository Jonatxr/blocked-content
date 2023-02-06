#!/bin/bash

# Demande des variables pour l'utilisateur MySQL et la base de données
read -p "Entrez le nom d'utilisateur MySQL: " USERNAME
read -sp "Entrez le mot de passe de l'utilisateur MySQL: " PASSWORD
echo
read -p "Entrez le nom de la base de données: " DATABASE

# Création de l'utilisateur MySQL et de la base de données
mysql -u root -p -e "CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD';"
mysql -u root -p -e "CREATE DATABASE $DATABASE;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO '$USERNAME'@'localhost';"

# Écriture des informations dans un fichier texte
info="Utilisateur: $USERNAME \nMot de passe: $PASSWORD \nBase de données: $DATABASE"
mkdir -p /infomysql/
echo -e $info > /infomysql/info