#!/bin/bash

# Spécifiez le nom d'utilisateur et l'adresse IP du serveur distant B (Carte)
remote_user="carteb"
remote_host="192.168.139.132"

server_user="servera"
server_host="192.168.139.131"

# Spécifiez le chemin du fichier pour la clé symétrique
symmetric_key_file="/home/$server_user/symmetric_key.bin"

# Spécifiez le chemin du fichier de sortie pour la clé symétrique chiffrée
encrypted_symmetric_key_file="/home/$server_user/encrypted_symmetric_key.bin"

# Spécifiez le chemin du fichier de sortie pour le résultat de la commande à distance
output_file="output_encrypt_and_send.txt"

# Spécifiez le chemin complet de la clé publique à utiliser
public_key_path="/home/$server_user/public_key.pem"

# Chiffrer la clé symétrique avec la clé publique
openssl rsautl -encrypt -inkey "$public_key_path" -pubin -in "$symmetric_key_file" -out "$encrypted_symmetric_key_file"

# Vérifier le code de retour de la commande OpenSSL
if [ $? -eq 0 ]; then
    echo "Clé symétrique chiffrée avec succès"
else
    echo "Échec du chiffrement de la clé symétrique"
    exit 0  # Quitter le script en cas d'échec
fi

# Copier la clé symétrique chiffrée depuis A vers B via SCP
scp "$encrypted_symmetric_key_file" "$remote_user@$remote_host:/home/$remote_user/"

# Vérifier le code de retour de la commande SCP
if [ $? -eq 0 ]; then
    echo "Clé symétrique chiffrée copiée avec succès vers B"
else
    echo "Échec de la copie de la clé symétrique chiffrée vers B"
    exit 0  # Quitter le script en cas d'échec
fi

# Connexion SSH avec clé privée depuis A vers B pour déchiffrer la clé symétrique
ssh -i /home/$server_user/.ssh/id_rsa "$remote_user@$remote_host" "
    openssl rsautl -decrypt -inkey /home/$remote_user/private_key.pem -passin pass:passphrase -in /home/$remote_user/encrypted_symmetric_key.bin -out /home/$remote_user/symmetric_key.bin
"

# Vérifier le code de retour de la commande SSH
if [ $? -eq 0 ]; then
    echo "Clé symétrique déchiffrée avec succès sur B"

    #Clean up sur A
    rm "$public_key_path" "$encrypted_symmetric_key_file"

    #Clean up sur B
    ssh -i /home/$server_user/.ssh/id_rsa "$remote_user@$remote_host" "
        rm /home/$remote_user/public_key.pem /home/$remote_user/encrypted_symmetric_key.bin /home/$remote_user/private_key.pem
    "

    exit 1 #Quitter si réussi
else
    echo "Échec du déchiffrement de la clé symétrique sur B"
    exit 0  # Quitter le script en cas d'échec
fi
