#!/bin/bash
source config.sh

# generate root ca
# -----------------------------------------------------------
rootca_key_path=${private_key_dir}/rootca.key.pem
gen_cert_key_ifnotexist $rootca_key_path


rootca_csr_path=${private_key_dir}/rootca.csr
if [ ! -f "$rootca_csr_path" ];then
  echo "generate root cert csr: $rootca_csr_path."
  openssl req -new -key $rootca_key_path -out $rootca_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=service"
else
  echo "$rootca_csr_path has been generated."
fi

rootca_cert_path=${certs_dir}/rootca.cer
if [ ! -f "$rootca_cert_path" ];then
  echo "generate root cert: $rootca_cert_path."
  openssl x509 -req -days $days -sha1 -extensions v3_ca -signkey $rootca_key_path -in $rootca_csr_path -out $rootca_cert_path
else
  echo "$rootca_cert_path has been generated."
fi

# generate server ca
#-----------------------------------------------------------
server_key_path=${private_key_dir}/server.key.pem
gen_cert_key_ifnotexist $server_key_path

server_csr_path=${private_key_dir}/server.csr
if [ ! -f "$server_csr_path" ];then
  echo "generate server cert csr: $server_csr_path."
  openssl req -new -key $server_key_path -out $server_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=gotty"
else
  echo "$server_csr_path has been generated."
fi

server_cert_path=${certs_dir}/server.cer
#ca_srl_path=${root}ca.srl
if [ ! -f "$server_cert_path" ];then
  echo "generate server cert: $server_cert_path."
  openssl x509 -req -days $days -sha1 -extensions v3_req -CA $rootca_cert_path -CAkey $rootca_key_path -CAserial ca.srl -CAcreateserial -in $server_csr_path -out $server_cert_path
else
  echo "$server_cert_path has been generated."
fi

