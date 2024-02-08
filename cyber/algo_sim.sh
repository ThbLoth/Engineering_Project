#!/bin/bash

server_user="servera"
remote_user="carteb"

server_host="192.168.139.131"
remote_host="192.168.139.132"

data_file="$1"

encrypted_data="data.enc"

symmetric_key_file="/home/$remote_user/symmetric_key.bin"

openssl enc -aes-256-cbc -salt -in "$data_file" -out "$encrypted_data" -pass file:"$symmetric_key_file"

scp "$encrypted_data" $server_user@$server_host:/home/$server_user/
echo "Données envoyées au serveur"

ssh -i /home/$remote_user/.ssh/id_rsa $server_user@$server_host "
    openssl enc -aes-256-cbc -d -in /home/$server_user/data.enc -out /home/$server_user/data.txt -pass file:/home/$server_user/symmetric_key.bin"
echo "Données déchiffrées sur le serveur"

#Exécution d'un script sur le serveur
ssh -i /home/$remote_user/.ssh/id_rsa $server_user@$server_host "
    /home/$server_user/process.sh"

#On chiffre les données proccessed sur le serveur en ssh
ssh -i /home/$remote_user/.ssh/id_rsa $server_user@$server_host "
    openssl enc -aes-256-cbc -salt -in /home/$server_user/data_processed.txt -out /home/$server_user/data_processed.enc -pass file:/home/$server_user/symmetric_key.bin"

#On envoie les données du serveur a la carte
scp $server_user@$server_host:/home/$server_user/data_processed.enc /home/$remote_user/

#On déchiffre les données sur la carte
openssl enc -aes-256-cbc -d -in /home/$remote_user/data_processed.enc -out /home/$remote_user/data_processed.txt -pass file:/home/$remote_user/symmetric_key.bin

