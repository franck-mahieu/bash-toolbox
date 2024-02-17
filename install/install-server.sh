#!/bin/bash

# Mettre à jour le système
sudo apt-get update

# Installer PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Configurer PostgreSQL
sudo -u postgres createuser --interactive
sudo -u postgres createdb framaweb

# Installer curl et unzip (nécessaires pour installer fnm et pm2)
sudo apt-get install curl unzip

# Installer fnm (Fast Node Manager)
curl -fsSL https://github.com/Schniz/fnm/raw/main/.ci/install.sh | bash

# Activer fnm
export PATH=$HOME/.fnm:$PATH
eval "`fnm env --multi`"

# Installer Node.js via fnm
fnm install latest

# Installer pnpm globalement
npm install -g pnpm

# Installer pm2 globalement via pnpm
pnpm add -g pm2

# Installer Nginx
sudo apt-get install nginx

# Obtenir et installer le certificat SSL
sudo certbot --nginx -d framaweb.fr

# Cloner le dépôt du projet Next.js
git clone https://github.com/franck-mahieu/starter-kit-next

# Aller dans le dossier du projet
cd starter-kit-next

# Installer les dépendances du projet avec pnpm
pnpm install

# Construire le projet avec pnpm
pnpm run build

# Démarrer le serveur Next.js avec pm2
pm2 start pnpm --name "nextjs" -- run start

# Configurer Nginx pour utiliser le certificat SSL
echo 'server {
    listen 80;
    server_name votre-domaine.com;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/votre-domaine.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/votre-domaine.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}' | sudo tee /etc/nginx/sites-available/framaweb

# Activer la configuration Nginx
sudo ln -s /etc/nginx/sites-available/framaweb /etc/nginx/sites-enabled/

# Redémarrer Nginx pour appliquer les modifications
sudo service nginx restart
