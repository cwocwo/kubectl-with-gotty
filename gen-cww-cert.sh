#!/bin/bash
source config.sh

root=/etc/pki/CA/
cww_key_path=${root}private/cww.key.pem
gen_cert_key_ifnotexist $cww_key_path

cww_csr_path=${root}private/cww.csr
if [ ! -f "$cww_csr_path" ];then
  echo "generate cww cert csr: $cww_csr_path."
  openssl req -new -key $cww_key_path -out $cww_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=cww"
else
  echo "$cww_csr_path has been generated."
fi

cww_cert_path=${root}certs/cww.cer
if [ ! -f "$cww_cert_path" ];then
  echo "generate root cert: $cww_cert_path."
  openssl x509 -req -days 3650 -sha1 -extensions v3_req -CA certs/ca.cer -CAkey private/cakey.pem -CAserial ca.srl -in private/client.csr -out certs/client.cer
  openssl x509 -req -days 3650 -sha1 -extensions v3_req -CA  -CAkey private/cakey.pem -CAserial ca.srl -CAcreateserial -in private/cww.csr -out certs/cww.cer
  openssl x509 -req -days 3650 -sha1 -extensions v3_ca -signkey $cww_key_path -in $cww_csr_path -out $cww_cert_path
else
  echo "$cww_cert_path has been generated."
fi



