#!/bin/bash

# Utiliser ping_check avec une adresse IP spécifique
result_ping=$(./ping_check.sh 192.168.78.131)


# Vérifier le code de retour de ping_check.sh
if [ $result_ping -eq 1 ]; then
    echo "Ping vers carte OK, prêt à communiquer"
fi

pub_key_on_server=$(./card_keys.sh)

# Vérifier le code de retour de card_keys.sh
if [ $? -eq 1 ]; then
    echo "Clé publique de la carte copiée sur le serveur, prêt pour génération et échange de la clé symétrique"
fi