#!/bin/bash

# Créer un lien symbolique de docker-compose.prod.yaml vers docker-compose.yaml
ln -s docker-compose.prod.yaml docker-compose.yaml

# Copier .env.example vers .env.prod
cp .env.example .env.prod

# Générer une chaîne de caractères aléatoire de 20 caractères pour POSTGRES_PASSWORD
random_postgres_password=$(openssl rand -base64 20 | tr -d '\n')

# Générer une autre chaîne de caractères aléatoire de 20 caractères pour SECRET_KEY_BASE
random_secret_key_base=$(openssl rand -base64 20 | tr -d '\n')

# Utiliser sed pour ajouter POSTGRES_HOST=postgres comme une nouvelle ligne dans .env.prod
sed -i '/^$/ { s/^$/POSTGRES_HOST=postgres/; :a; n; ba; }' .env.prod
if ! grep -q '^POSTGRES_USER=postgres$' .env.prod; then
    echo -e "\nPOSTGRES_USER=postgres" >> .env.prod
fi


# Utiliser sed pour remplacer les valeurs de POSTGRES_PASSWORD et SECRET_KEY_BASE dans .env.prod
sed -i "s/POSTGRES_PASSWORD=/POSTGRES_PASSWORD=$random_postgres_password/" .env.prod
sed -i "s/SECRET_KEY_BASE=/SECRET_KEY_BASE=$random_secret_key_base/" .env.prod

echo "Le lien symbolique a été créé, .env.prod a été copié, et POSTGRES_HOST a été ajouté comme une nouvelle ligne, et les valeurs aléatoires ont été définies dans .env.prod."


# Nom du fichier docker-compose.yaml
COMPOSE_FILE="docker-compose.yaml"

# Vérifier si le fichier existe
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Le fichier $COMPOSE_FILE n'existe pas."
    exit 1
fi

# Extraire les montages locaux du fichier docker-compose.yaml
LOCAL_MOUNTS=$(grep -E '^\s+- (\.\/|\/)[^:]+:[^:]+/' "$COMPOSE_FILE" | sed -E 's/^\s+- ((\.\/|\/)[^:]+):\/[^:]+/\1/')

# Parcourir les montages locaux et demander confirmation avant d'exécuter chcon
for MOUNT in $LOCAL_MOUNTS; do

    if mount | grep -q "on $MOUNT type cifs "; then
        echo "Montage CIFS trouvé sur le chemin $MOUNT. Exécution de setsebool."
        setsebool -P virt_use_samba 1
        break
    else
        echo "Voulez-vous exécuter la commande chcon pour $MOUNT ? (y/n)"
        read -r response
        if [[ $response =~ ^[Yy]$ ]]; then
            echo "Changement des permissions pour $MOUNT..."
            chcon -Rt svirt_sandbox_file_t "$MOUNT"
        else
            echo "La commande chcon pour $MOUNT a été ignorée."
        fi
    fi
done

echo "Changement des permissions terminé."

