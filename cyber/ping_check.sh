#!/bin/bash

# Vérification du nombre d'arguments
if [ $# -ne 1 ]; then
    echo "Utilisation: $0 <adresse_ip>"
    exit 1
fi

# Adresse IP fournie en argument
host=$1

# Exécution de la commande ping
ping -c 1 $host > /dev/null 2>&1

# Vérification du code de retour de la commande ping
if [ $? -eq 0 ]; then
    # Retourne 1 si la machine est accessible
    echo "1"
else
    # Retourne 0 si la machine n'est pas accessible
    echo "0"
fi
