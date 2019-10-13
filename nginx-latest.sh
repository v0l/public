#!/bin/bash

apt-get update
apt-get install build-essential libpcre3-dev libz-dev

OPENSSL_V="openssl-1.1.1d"
NGINX_V="nginx-1.17.4"

wget https://www.openssl.org/source/$OPENSSL_V.tar.gz
tar xfv $OPENSSL_V.tar.gz

wget http://nginx.org/download/$NGINX_V.tar.gz
tar xfv $NGINX_V.tar.gz

cd $NGINX_V

./configure --with-openssl=../$OPENSSL_V --with-ipv6 --with-threads --with-http_ssl_module --with-http_v2_module
make -j8
make install

rm -rf /usr/sbin/nginx
ln /usr/local/nginx/sbin/nginx /usr/sbin/nginx
