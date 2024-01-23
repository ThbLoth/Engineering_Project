#!/bin/bash

# Vérifier sur quelle machine le script est exécuté
current_machine=$(whoami)

if [ "$current_machine" == "servera" ]; then
    # Code à exécuter sur A (serveur principal)
    if [ "$#" -eq 0 ]; then
        echo "Erreur : Aucun fichier spécifié. Utilisation : $0 chemin/vers/le/fichier"
        exit 1
    fi
    
    file_to_send="$1"
    encrypted_file="fichier_chiffre.enc"
    # Spécifiez le chemin du fichier de clé symétrique partagée entre les machines
    symmetric_key_file="/home/servera/symmetric_key.bin"

    openssl enc -aes-256-cbc -salt -in "$file_to_send" -out "$encrypted_file" -pass file:"$symmetric_key_file"

    # Envoyer le fichier chiffré de A vers B
    scp "$encrypted_file" cardb@192.168.78.131:/home/cardb/
    echo "Fichier chiffré envoyé avec succès de A vers B"

    #Decrypter le fichier sur B via ssh
    ssh -i /home/servera/.ssh/id_rsa cardb@192.168.78.131 "
        openssl enc -aes-256-cbc -d -in /home/cardb/fichier_chiffre.enc -out /home/cardb/fichier_dechiffre.txt -pass file:/home/cardb/symmetric_key.bin"

    # Vérifier le code de retour de la commande SSH
    if [ $? -eq 0 ]; then
        echo "Fichier déchiffré avec succès sur B"

        #Clean up sur A
        rm "$encrypted_file"

        #Clean up sur B
        ssh -i /home/servera/.ssh/id_rsa cardb@192.168.78.131 "
            rm /home/cardb/fichier_chiffre.enc"
        
        exit 1 #Quitter si réussi
    else
        echo "Échec du déchiffrement du fichier sur B"
        #Clean up sur A et B
        rm "$encrypted_file"
        ssh -i /home/servera/.ssh/id_rsa cardb@192.168.78.131 "
            rm /home/cardb/fichier_chiffre.enc"
        exit 0  # Quitter le script en cas d'échec
    fi

elif [ "$current_machine" == "cardb" ]; then
    if [ "$#" -eq 0 ]; then
        echo "Erreur : Aucun fichier spécifié. Utilisation : $0 chemin/vers/le/fichier"
        exit 1
    fi
    
    file_to_send="$1"
    encrypted_file="fichier_chiffre.enc"
    # Spécifiez le chemin du fichier de clé symétrique partagée entre les machines
    symmetric_key_file="/home/cardb/symmetric_key.bin"

    openssl enc -aes-256-cbc -salt -in "$file_to_send" -out "$encrypted_file" -pass file:"$symmetric_key_file"

    # Envoyer le fichier chiffré de B vers A
    scp "$encrypted_file" servera@192.168.78.130:/home/servera/
    echo "Fichier chiffré envoyé avec succès de B vers A"

    #Decrypter le fichier sur A via ssh
    ssh -i /home/cardb/.ssh/id_rsa servera@192.168.78.130 "
        openssl enc -aes-256-cbc -d -in /home/servera/fichier_chiffre.enc -out /home/servera/fichier_dechiffre.txt -pass file:/home/servera/symmetric_key.bin"

    # Vérifier le code de retour de la commande SSH
    if [ $? -eq 0 ]; then
        echo "Fichier déchiffré avec succès sur A"

        #Clean up sur B
        rm "$encrypted_file"

        #Clean up sur A
        ssh -i /home/cardb/.ssh/id_rsa servera@192.168.78.130 "
            rm /home/servera/fichier_chiffre.enc"
        
        exit 1 #Quitter si réussi
    else
        echo "Échec du déchiffrement du fichier sur A"
        #Clean up sur A et B
        rm "$encrypted_file"
        ssh -i /home/cardb/.ssh/id_rsa servera@192.168.78.130 "
            rm /home/servera/fichier_chiffre.enc"
        exit 0  # Quitter le script en cas d'échec
    fi

else
    echo "Erreur : Machine non reconnue."
    exit 1
fi
