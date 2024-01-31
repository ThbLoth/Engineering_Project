#!/bin/bash

# Utiliser ping_check avec une adresse IP spécifique
result_ping=$(./ping_check.sh 192.168.139.132)


# Vérifier le code de retour de ping_check.sh
if [ $result_ping -eq 1 ]; then
    echo "Ping vers carte OK, prêt à commencer la procédure"
fi

pub_key_on_server=$(./card_keys.sh)

# Vérifier le code de retour de card_keys.sh
if [ $? -eq 1 ]; then
    echo "Clé publique de la carte copiée sur le serveur, prêt pour génération et échange de la clé symétrique"
fi

#Génération de la clé symétrique et vérification

sym_key=$(./symetric_key.sh)
if [ $? -eq 1 ]; then
    echo "Clé symétrique générée avec succès"
fi

#Echange de la clé symétrique et vérification

exchange_sym_key=$(./cyp_and_send.sh)
if [ $? -eq 1 ]; then
    echo "Clé symétrique échangée avec succès, fichiers nettoyés"
    echo "Préparation terminée, communication sécurisée établie"
    exit 0;
fi