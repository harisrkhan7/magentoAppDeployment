#!/bin/bash -v
MAGENTO_REPO_USERNAME="${MAGENTO_REPO_USERNAME}"
MAGENTO_REPO_PASSWORD="${MAGENTO_REPO_PASSWORD}"
DB_HOST= "${DB_HOST}"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASS="${DB_PASSWORD}"
SERVER_NAME="$(dig +short myip.opendns.com @resolver1.opendns.com)"
BASE_URL="http://$SERVER_NAME/"
ADMIN_FIRST_NAME="${ADMIN_FIRST_NAME}"
ADMIN_LAST_NAME="${ADMIN_LAST_NAME}"
ADMIN_EMAIL="${ADMIN_EMAIL}"
ADMIN_USERNAME="${ADMIN_USERNAME}"
ADMIN_PASSWORD="${ADMIN_PASSWORD}"
BACKEND_FRONTNAME="${BACKEND_FRONTNAME}"
LANGUAGE="${LANGUAGE}"
CURRENCY="${CURRENCY}"
TIME_ZONE="${TIME_ZONE}"

#Update the package definitions
apt-get -y update

#Updgrade all existing packages to latest
DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y -u  -o \
   Dpkg::Options::="--force-confdef" --allow-downgrades \
   --allow-remove-essential --allow-change-held-packages \
   --allow-change-held-packages --allow-unauthenticated;
   
##### Nginx Installation

#Install Nginx
apt-get -y install nginx

#Dependencies for adding ppa repository
sudo apt-get install -y software-properties-common

#Add repository for php
sudo add-apt-repository -y ppa:ondrej/php

#Refresh the repository list
apt-get -y update

#Install PHP extensions
sudo apt-get install -y php7.2-common php7.2-gd php7.2-mysql php7.2-curl php7.2-intl php7.2-xsl php7.2-mbstring php7.2-zip php7.2-bcmath php7.2-iconv php7.2-soap

#Install php-fpm 
apt-get -y install php7.2-fpm php7.2-cli

# Restart php-fpm service
systemctl restart php7.2-fpm

##### Nginx Installation

#Go to Docroot
cd /var/www/html

#Install Latest Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

#Update composer with magento credentials
cat > /root/.composer/auth.json << EOF
{
    "http-basic": {
        "repo.magento.com": {
            "username": "$MAGENTO_REPO_USERNAME",
            "password": "$MAGENTO_REPO_PASSWORD"
        }
    }
} 
EOF

#Create a new project using Magneto Open Source
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition magento 

#Change Permissions of magneto install directory
 cd /var/www/html/magento
 
 find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
 find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
 chown -R :www-data . # Ubuntu
 chmod u+x bin/magento
 chmod -R a+w+r var
 chmod -R a+w+r app

 cd /var/www/html/magento#Install Magneto

 sudo bin/magento setup:install \
 --base-url="$BASE_URL" \
 --db-host="$DB_HOST" \
 --db-name="$DB_NAME" \
 --db-user="$DB_USER" \
 --db-password="$DB_PASS" \
 --backend-frontname="$BACKEND_FRONTNAME" \
 --admin-firstname="$ADMIN_FIRST_NAME" \
 --admin-lastname="$ADMIN_LAST_NAME" \
 --admin-email="$ADMIN_EMAIL" \
 --admin-user="$ADMIN_USERNAME" \
 --admin-password="$ADMIN_PASSWORD" \
 --language="$LANGUAGE" \
 --currency="$CURRENCY" \
 --timezone="$TIMEZONE" \
 --use-rewrites=1

#Switch to developer mode
cd /var/www/html/magento/bin  
./magento deploy:mode:set developer

#Create a new virtual host for your Magento Site
cat > /etc/nginx/sites-available/magento << EOF 
upstream fastcgi_backend {
     server  unix:/run/php/php7.2-fpm.sock;
 }

 server {
     listen 80;
     server_name $SERVER_NAME;
     set \$MAGE_ROOT /var/www/html/magento;
     include /var/www/html/magento/nginx.conf.sample;
 } 
EOF

ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled
#Link the newly created Virtual Host to the nginx configuration

#Verify the nginx syntax
nginx -t

#Restart nginx to persist changes
systemctl restart nginx

config_service.sh --portrange="${PORT_RANGE}"