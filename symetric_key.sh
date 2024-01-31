#!/bin/bash

server_user="servera"

# Spécifiez le chemin du fichier pour la clé symétrique
symmetric_key_file="/home/servera/symmetric_key.bin"

# Générer une clé symétrique avec OpenSSL (AES-256 en exemple)
openssl rand -out "$symmetric_key_file" -hex 32

# Vérifier le code de retour de la commande OpenSSL
if [ $? -eq 0 ]; then
    echo "Clé symétrique générée avec succès et enregistrée dans $symmetric_key_file"
    exit 1
else
    echo "Échec de la génération de la clé symétrique"
    exit 0 # Quitter le script en cas d'échec
fi
