#!/bin/bash
source config.sh

root=/etc/pki/CA/
server_key_path=${root}private/server.key.pem
gen_cert_key_ifnotexist $server_key_path

server_csr_path=${root}private/server.csr
if [ ! -f "$server_csr_path" ];then
  echo "generate root cert csr: $server_csr_path."
  openssl req -new -key $server_key_path -out $server_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=gotty"
else
  echo "$server_csr_path has been generated."
fi

server_cert_path=${root}certs/server.cer
if [ ! -f "$server_cert_path" ];then
  echo "generate root cert: $server_cert_path."
  openssl x509 -req -days 3650 -sha1 -extensions v3_req -CA  -CAkey private/cakey.pem -CAserial ca.srl -CAcreateserial -in private/server.csr -out certs/server.cer
  openssl x509 -req -days 3650 -sha1 -extensions v3_ca -signkey $server_key_path -in $server_csr_path -out $server_cert_path
else
  echo "$server_cert_path has been generated."
fi



