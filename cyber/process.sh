#!/bin/bash

# Chemin du fichier d'entrée
inputFile="data.txt"
# Chemin du fichier de sortie
outputFile="data_processed.txt"

# Vérifier si le fichier d'entrée existe
if [ ! -f "$inputFile" ]; then
    echo "Le fichier $inputFile n'existe pas."
    exit 1
fi

# Créer ou vider le fichier de sortie
> "$outputFile"

# Lire chaque ligne du fichier d'entrée
while IFS= read -r line; do
    # Convertir la chaîne binaire en caractère ASCII et l'ajouter au fichier de sortie
    printf "\\$(printf '%03o' "$((2#$line))")" >> "$outputFile"
done < "$inputFile"

echo "Conversion terminée. Les données sont dans $outputFile."
