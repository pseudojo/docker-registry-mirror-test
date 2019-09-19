#!/bin/bash
# https://zetawiki.com/wiki/리눅스_자체서명_SSL_인증서_생성

BASEDIR=$( cd $(dirname $0) && pwd )
CERTS_DIR=$BASEDIR/certs
DAYS=36500

mkdir -p $CERTS_DIR
cd $CERTS_DIR

echo -e "\n** Create private key file : server.key"
openssl genrsa -des3 -out server.key 2048

echo -e "\n** Remove password in private key file"
cp server.key server.key.origin
openssl rsa -in server.key.origin -out server.key
rm -f server.key.origin

echo -e "\n** Create certification request file : server.csr"
echo -e "\n- Must be skip 'A challenge password and an optional company name'"
echo -e "\n- KR / Seoul / Seoul / ***** / ***** / ***** / ***********************"
openssl req -new -key server.key -out server.csr

echo -e "\n** Create certification file : server.crt"
openssl x509 -req -days $DAYS -in server.csr -signkey server.key -out server.crt

echo -e "\n** Create server.pem file"
cat server.key > server.pem
cat server.crt >> server.pem

echo -e "\n** Check private key and self-signed certification"
cat server.key | head -3
echo "**********************"
cat server.crt | head -3

echo -e "\n\nDone."

