#!/bin/bash

# Vérifier sur quelle machine le script est exécuté
current_machine=$(whoami)
server_user="servera"
remote_user="carteb"

server_host="192.168.139.131"
remote_host="192.168.139.132"

if [ "$current_machine" == "$server_user" ]; then
    # Code à exécuter sur A (serveur principal)
    if [ "$#" -eq 0 ]; then
        echo "Erreur : Aucun fichier spécifié. Utilisation : $0 chemin/vers/le/fichier"
        exit 1
    fi
    
    file_to_send="$1"
    encrypted_file="fichier_chiffre.enc"
    # Spécifiez le chemin du fichier de clé symétrique partagée entre les machines
    symmetric_key_file="/home/$server_user/symmetric_key.bin"

    openssl enc -aes-256-cbc -salt -in "$file_to_send" -out "$encrypted_file" -pass file:"$symmetric_key_file"

    # Envoyer le fichier chiffré de A vers B
    scp "$encrypted_file" $remote_user@$remote_host:/home/$remote_user/
    echo "Fichier chiffré envoyé avec succès de A vers B"

    #Decrypter le fichier sur B via ssh
    ssh -i /home/$server_user/.ssh/id_rsa $remote_user@$remote_host "
        openssl enc -aes-256-cbc -d -in /home/$remote_user/fichier_chiffre.enc -out /home/$remote_user/fichier_dechiffre.txt -pass file:/home/$remote_user/symmetric_key.bin"

    # Vérifier le code de retour de la commande SSH
    if [ $? -eq 0 ]; then
        echo "Fichier déchiffré avec succès sur B"

        #Clean up sur A
        rm "$encrypted_file"

        #Clean up sur B
        ssh -i /home/$server_user/.ssh/id_rsa $remote_user@$remote_host "
            rm /home/$remote_user/fichier_chiffre.enc"
        
        exit 1 #Quitter si réussi
    else
        echo "Échec du déchiffrement du fichier sur B"
        #Clean up sur A et B
        rm "$encrypted_file"
        ssh -i /home/$server_user/.ssh/id_rsa $remote_user@$remote_host "
            rm /home/$remote_user/fichier_chiffre.enc"
        exit 0  # Quitter le script en cas d'échec
    fi

elif [ "$current_machine" == "$remote_user" ]; then
    if [ "$#" -eq 0 ]; then
        echo "Erreur : Aucun fichier spécifié. Utilisation : $0 chemin/vers/le/fichier"
        exit 1
    fi
    
    file_to_send="$1"
    encrypted_file="fichier_chiffre.enc"
    # Spécifiez le chemin du fichier de clé symétrique partagée entre les machines
    symmetric_key_file="/home/remote_user/symmetric_key.bin"

    openssl enc -aes-256-cbc -salt -in "$file_to_send" -out "$encrypted_file" -pass file:"$symmetric_key_file"

    # Envoyer le fichier chiffré de B vers A
    scp "$encrypted_file" $server_user@$server_host:/home/$server_user/
    echo "Fichier chiffré envoyé avec succès de B vers A"

    #Decrypter le fichier sur A via ssh
    ssh -i /home/$remote_user/.ssh/id_rsa $server_user@$server_host "
        openssl enc -aes-256-cbc -d -in /home/server$server_usera/fichier_chiffre.enc -out /home/$server_user/fichier_dechiffre.txt -pass file:/home/$server_user/symmetric_key.bin"

    # Vérifier le code de retour de la commande SSH
    if [ $? -eq 0 ]; then
        echo "Fichier déchiffré avec succès sur A"

        #Clean up sur B
        rm "$encrypted_file"

        #Clean up sur A
        ssh -i /home/$remote_user/.ssh/id_rsa $server_user@$server_host "
            rm /home/$server_user/fichier_chiffre.enc"
        
        exit 1 #Quitter si réussi
    else
        echo "Échec du déchiffrement du fichier sur A"
        #Clean up sur A et B
        rm "$encrypted_file"
        ssh -i /home/$remote_user/.ssh/id_rsa $server_user@$server_host "
            rm /home/$server_user/fichier_chiffre.enc"
        exit 0  # Quitter le script en cas d'échec
    fi

else
    echo "Erreur : Machine non reconnue."
    exit 1
fi
