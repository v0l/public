#!/bin/bash

apt-get update
apt-get install build-essential libpcre3-dev libz-dev git

OPENSSL_V="openssl-1.1.0h"
NGINX_V="nginx-1.15.0"

wget https://www.openssl.org/source/$OPENSSL_V.tar.gz
tar xfv $OPENSSL_V.tar.gz

wget http://nginx.org/download/$NGINX_V.tar.gz
tar xfv $NGINX_V.tar.gz

git clone https://github.com/arut/nginx-rtmp-module.git

cd $NGINX_V

./configure --with-openssl=../$OPENSSL_V --add-module=../nginx-rtmp-module --with-ipv6 --with-threads --with-http_ssl_module --with-http_v2_module
make -j8
make install

ln /usr/local/nginx/sbin/nginx /usr/sbin/nginx
