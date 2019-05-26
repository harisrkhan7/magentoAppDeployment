#!/bin/bash -v
echo "Initialising Magento Install" >> /var/log/installMagentoProgress.log

MAGENTO_REPO_USERNAME="${MAGENTO_REPO_USERNAME}"
MAGENTO_REPO_PASSWORD="${MAGENTO_REPO_PASSWORD}"
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASS="${DB_PASSWORD}"
SERVER_NAME="${HOST_NAME}"
REDIS_HOST_NAME="${REDIS_HOST_NAME}"
REDIS_HOST_PASSWORD="${REDIS_HOST_PASSWORD}"
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

echo "MAGENTO_REPO_USERNAME=$MAGENTO_REPO_USERNAME" >> /var/log/installMagentoProgress.log
echo "MAGENTO_REPO_PASSWORD=$MAGENTO_REPO_PASSWORD" >> /var/log/installMagentoProgress.log
echo "DB_HOST=$DB_HOST" >> /var/log/installMagentoProgress.log
echo "DB_NAME=$DB_NAME" >> /var/log/installMagentoProgress.log
echo "DB_USER=$DB_USER" >> /var/log/installMagentoProgress.log
echo "DB_PASSWORD=$DB_PASS" >> /var/log/installMagentoProgress.log
echo "REDIS_HOST_NAME=$REDIS_HOST_NAME" >>/var/log/installMagentoProgress.log
echo "REDIS_HOST_PASSWORD=$REDIS_HOST_PASSWORD" >> /var/log/installMagentoProgress.log
echo "SERVER_NAME=$SERVER_NAME" >> /var/log/installMagentoProgress.log
echo "BASE_URL=http://$SERVER_NAME/" >> /var/log/installMagentoProgress.log
echo "ADMIN_FIRST_NAME=$ADMIN_FIRST_NAME" >> /var/log/installMagentoProgress.log
echo "ADMIN_LAST_NAME=$ADMIN_LAST_NAME" >> /var/log/installMagentoProgress.log
echo "ADMIN_EMAIL=$ADMIN_EMAIL" >> /var/log/installMagentoProgress.log
echo "ADMIN_USERNAME=$ADMIN_USERNAME" >> /var/log/installMagentoProgress.log
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> /var/log/installMagentoProgress.log
echo "BACKEND_FRONTNAME=${BACKEND_FRONTNAME}" >> /var/log/installMagentoProgress.log
echo "LANGUAGE=$LANGUAGE" >> /var/log/installMagentoProgress.log
echo "CURRENCY=$CURRENCY" >> /var/log/installMagentoProgress.log
echo "TIME_ZONE=$TIME_ZONE" >> /var/log/installMagentoProgress.log

echo "Updating Package Definitions" >> /var/log/installMagentoProgress.log
#Update the package definitions
apt-get -y update

echo "Updgrading Packages" >> /var/log/installMagentoProgress.log
#Updgrade all existing packages to latest
DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y -u  -o \
   Dpkg::Options::="--force-confdef" --allow-downgrades \
   --allow-remove-essential --allow-change-held-packages \
   --allow-change-held-packages --allow-unauthenticated;

##### Nginx Installation

echo "Installing Nginx" >> /var/log/installMagentoProgress.log
#Install Nginx
apt-get -y install nginx

echo "Installing Software-Properties-Common" >> /var/log/installMagentoProgress.log
#Dependencies for adding ppa repository
sudo apt-get install -y software-properties-common 

echo "Installing Ppa:ondrej/php" >> /var/log/installMagentoProgress.log
#Add repository for php
sudo add-apt-repository -y ppa:ondrej/php

#Refresh the repository list
apt-get -y update

echo "Installing PHP Extensions" >> /var/log/installMagentoProgress.log
#Install PHP extensions
sudo apt-get install -y php7.2-common php7.2-gd php7.2-mysql php7.2-curl php7.2-intl php7.2-xsl php7.2-mbstring php7.2-zip php7.2-bcmath php7.2-iconv php7.2-soap

echo "Installing PHP fpm" >> /var/log/installMagentoProgress.log
#Install php-fpm 
apt-get -y install php7.2-fpm php7.2-cli

echo "Restarting PHP service" >> /var/log/installMagentoProgress.log
# Restart php-fpm service
systemctl restart php7.2-fpm

##### Nginx Installation

#Go to Docroot
cd /var/www/html

echo "Installing Composer" >> /var/log/installMagentoProgress.log
#Install Latest Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer
#Set composer home directory
export COMPOSER_HOME="$HOME/.composer/"

echo "Updating Composer with Magento Credentials " >> /var/log/installMagentoProgress.log
#Update composer with magento credentials
composer config -a -g http-basic.repo.magento.com $MAGENTO_REPO_USERNAME $MAGENTO_REPO_PASSWORD >> /var/log/installMagento.log 2>&1

echo "Creating Composer Project" >> /var/log/installMagentoProgress.log
#Create a new project using Magneto Open Source
composer create-project --no-interaction --repository=https://repo.magento.com/ magento/project-community-edition magento  >> /var/log/installMagento.log 2>&1

echo "Changing Permissions of Magento Install Directory " >> /var/log/installMagentoProgress.log
#Change Permissions of magneto install directory
cd /var/www/html/magento
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R :www-data . 

# Ubuntu
chmod u+x bin/magento
chmod -R a+w+r var
chmod -R a+w+r app

cd /var/www/html/magento
echo "Installing Magento" >> /var/log/installMagentoProgress.log

#Install Magneto
sudo bin/magento setup:install \
 --base-url=$BASE_URL \
 --db-host=$DB_HOST \
 --db-name=$DB_NAME \
 --db-user=$DB_USER \
 --db-password=$DB_PASS \
 --backend-frontname=$BACKEND_FRONTNAME \
 --admin-firstname=$ADMIN_FIRST_NAME \
 --admin-lastname=$ADMIN_LAST_NAME \
 --admin-email=$ADMIN_EMAIL \
 --admin-user=$ADMIN_USERNAME \
 --admin-password=$ADMIN_PASSWORD \
 --language=$LANGUAGE \
 --currency=$CURRENCY \
 --timezone=$TIMEZONE \
 --session-save=redis \
 --session-save-redis-host=$REDIS_HOST_NAME \
 --session-save-redis-password=$REDIS_HOST_PASSWORD \
 --session-save-redis-log-level=3 \
 --session-save-redis-db=2 \
 --use-rewrites=1 >> /var/log/installMagento.log 2>&1

#echo "Set Cookie Domain" >> /var/log/installMagentoProgress.log
#sudo -E php bin/magento config:set web/cookie/cookie_domain $SERVER_NAME >> /var/log/installMagento.log 2>&1

#Re Index Magento
echo "Re Indexing Magento and Flushing Cache Storage" >> /var/log/installMagentoProgress.log
cd /var/www/html/magento
bin/magento indexer:reindex >> /var/log/installMagento.log 2>&1
php bin/magento cache:flush >> /var/log/installMagento.log 2>&1



echo "Switching to Developer Mode" >> /var/log/installMagentoProgress.log
#Switch to developer mode
cd /var/www/html/magento/bin 
./magento deploy:mode:set developer

echo "Creating New Virtual Host " >> /var/log/installMagentoProgress.log
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

echo "Linking New Virtual Host " >> /var/log/installMagentoProgress.log
#Link the newly created Virtual Host to the nginx configuration
ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled

echo "Verifying Virtual Host Template Syntax " >> /var/log/installMagentoProgress.log
#Verify the nginx syntax
nginx -t

echo "Restarting Nginx " >> /var/log/installMagentoProgress.log
#Restart nginx to persist changes
systemctl restart nginx

config_service.sh --portrange="${PORT_RANGE}"

echo "Finalising Magento Install" >> /var/log/installMagentoProgress.log