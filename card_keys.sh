#!/bin/bash

# Spécifiez le nom d'utilisateur et l'adresse IP du serveur distant B (Carte)
remote_user="cardb"
remote_host="192.168.78.131"

server_user="servera"
server_host="192.168.78.130"

# Commande à exécuter à distance sur B (Carte)
remote_command="
    openssl genpkey -algorithm RSA -out /home/$remote_user/private_key.pem -aes256 -pass pass:passphrase &&
    openssl rsa -pubout -in /home/$remote_user/private_key.pem -out /home/$remote_user/public_key.pem -passin pass:passphrase
"

# Connexion SSH avec clé privée depuis A vers B
ssh -i /home/servera/.ssh/id_rsa "$remote_user@$remote_host" "$remote_command"

# Vérifier le code de retour de la commande SSH
if [ $? -eq 0 ]; then
    echo "Commande à distance exécutée avec succès sur B (Carte)"
else
    exit 0  # Quitter le script en cas d'échec
fi

# Copier la clé publique depuis B (Carte) vers A
scp -i /home/servera/.ssh/id_rsa "$remote_user@$remote_host:/home/$remote_user/public_key.pem" "/home/$server_user/Bureau"

# Vérifier le code de retour de la commande SCP
if [ $? -eq 0 ]; then
    exit 1 #Quitter si réussi
else
    echo "Échec de la copie de la clé publique depuis B (Carte) vers A"
    exit 0
fi
