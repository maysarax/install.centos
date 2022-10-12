#!/bin/bash

################################################################################
# Script for installing Moodle v4.0 MariaDB, Nginx and Php 7.4 on Ubuntu 22.04
# Authors: Henry Robert Muwanika

# Make a new file:
# sudo nano install_moodle.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install_moodle.sh
# Execute the script to install Moodle:
# ./install_moodle.sh
#
################################################################################
#
# Set to "True" to install certbot and have ssl enabled, "False" to use http
ENABLE_SSL="True"
# Set the website name
WEBSITE_NAME="https://elearning.themsc.net/moodle2/"
# Provide Email to register ssl certificate
ADMIN_EMAIL="msc21developer@gmail.com"

#
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n============= Update Server ================"
sudo yum update && sudo yum upgrade -y
sudo yum autoremove -y

#--------------------------------------------------
# Install Nginx Web server
#--------------------------------------------------
sudo yum install -y nginx
sudo systemctl stop nginx.service
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

#--------------------------------------------------
# Installation of Mariadb server
#--------------------------------------------------
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=10.8
sudo yum update
sudo yum install -y mariadb-server mariadb-client
sudo systemctl stop mariadb.service
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service

# sudo mysql_secure_installation

# sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf 
# add the below statements
# [mysqld]
# innodb_file_per_table = 1
# innodb_file_format = Barracuda
# innodb_large_prefix = ON

sudo systemctl restart mysql.service

sudo mysql -uroot --password="" -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -uroot --password="" -e "CREATE USER 'moodle_admin'@'localhost' IDENTIFIED BY 'abc1234!';"
sudo mysql -uroot --password="" -e "GRANT ALL ON moodle.* TO 'moodle_admin'@'localhost' WITH GRANT OPTION;"
sudo mysql -uroot --password="" -e "FLUSH PRIVILEGES;"
sudo mysqladmin -uroot --password="" reload 2>/dev/null
sudo systemctl restart mysql.service

#--------------------------------------------------
# Installation of PHP
#--------------------------------------------------
sudo yum install -y software-properties-common ca-certificates lsb-release  dirmngr
sudo yum update

yum install -y php7.4 php7.4-fpm php7.4-common php7.4-mysql php7.4-gmp php7.4-curl php7.4-intl php7.4-mbstring php7.4-soap php7.4-xmlrpc php7.4-gd \
php7.4-xml php7.4-cli php7.4-zip php7.4-soap php7.4-iconv php7.4-json php7.4-pspell unzip git curl libpcre3 libpcre3-dev graphviz aspell ghostscript clamav

sudo systemctl is-enabled php7.4-fpm 

# sudo nano /etc/php/7.4/fpm/php.ini
# file_uploads = On
# allow_url_fopen = On
# short_open_tag = On
# memory_limit = 256M
# cgi.fix_pathinfo = 0
# upload_max_filesize = 100M
# max_execution_time = 360
# date.timezone = Africa/Kigali

systemctl restart php7.4-fpm

#--------------------------------------------------
# Installation of Moodle
#--------------------------------------------------
wget https://download.moodle.org/download.php/direct/stable400/moodle-latest-400.tgz
sudo tar -zxvf moodle-latest-400.tgz 
sudo mv moodle /var/www/html/

cd /var/www/html/moodle/
sudo cp config-dist.php config.php
sudo nano config.php

sudo chown -R www-data:www-data /var/www/html/moodle
sudo chmod -R 755 /var/www/html/moodle

sudo mkdir /var/moodledata
sudo chown -R www-data:www-data /var/moodledata
sudo chmod -R  755 /var/moodledata

sudo mkdir -p /var/quarantine
sudo chown -R www-data /var/quarantine

sudo cat <<EOF > /etc/nginx/sites-available/moodle
#########################################################################
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/moodle;
    index  index.php index.html index.htm;
    server_name $WEBSITE_NAME;
    
    client_max_body_size 200M;
    
    autoindex off;
    location / {
        try_files $uri $uri/ =404;
    }
    
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }	
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }	
    location /dataroot/ {
    internal;
    alias /var/moodledata/;
    }
    location ~ [^/]\.php(/|$) {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
#########################################################################
EOF

nginx -t

sudo ln -s /etc/nginx/sites-available/moodle /etc/nginx/sites-enabled/

sudo systemctl reload nginx
sudo systemctl reload php7.4-fpm


echo -e "Access moodle https://$WEBSITE_NAME/install.php"
