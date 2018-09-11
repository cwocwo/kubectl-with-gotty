#!/bin/bash

source config.sh

username=$1
if [ -z "$username" ]; then 
  echo "username must be provided. "
  exit
fi
# generate user ca
#--------------------------------------------------------------------------
user_key_path=${private_key_dir}/${username}.key.pem
gen_cert_key_ifnotexist $user_key_path

user_csr_path=${private_key_dir}/${username}.csr
if [ ! -f "$user_csr_path" ];then
  echo "generate user[${username}] cert csr: $user_csr_path."
  openssl req -new -key $user_key_path -out $user_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=${username}"
else
  echo "$user_csr_path has been generated."
fi

user_cert_path=${certs_dir}/${username}.cer
if [ ! -f "$user_cert_path" ];then
  echo "generate user[${username}] cert: $user_cert_path."
  openssl x509 -req -days $days -sha1 -extensions v3_req -CA $rootca_cert_path -CAkey $rootca_key_path -CAserial ca.srl -in $user_csr_path -out $user_cert_path
else
  echo "$user_cert_path has been generated."
fi

openssl pkcs12 -export -clcerts -in $user_cert_path -inkey $user_cert_key_path -out ${clients_dir}/${username}.client.p12

