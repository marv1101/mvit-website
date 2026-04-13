$DOMAIN="mphion.de"

mkdir -p ./nginx/certbot/conf/live/$DOMAIN
mkdir -p ./nginx/certbot/conf/archive/$DOMAIN

# Zertifikat für die Initialisierung von Nginx erstellen
# Certbot erstetzt das Zertifikat nach start von nginx durch ein Letsencrypt Zertifikat
openssl req -x509 -nodes -newkey rsa:4096 -keyout ./nginx/certbot/conf/live/$DOMAIN/privkey.pem -out ./nginx/certbot/conf/live/$DOMAIN/fullchain.pem -days 3650 -subj "/CN=$DOMAIN"