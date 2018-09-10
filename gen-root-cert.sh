#!/bin/bash
source config.sh

days=3650
root=/etc/pki/CA/
rootca_key_path=${root}private/rootca.key.pem
gen_cert_key_ifnotexist $rootca_key_path


rootca_csr_path=${root}private/rootca.csr
if [ ! -f "$rootca_csr_path" ];then
  echo "generate root cert csr: $rootca_csr_path."
  openssl req -new -key $rootca_key_path -out $rootca_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=service"
else
  echo "$rootca_csr_path has been generated."
fi

rootca_cert_path=${root}certs/rootca.cer
if [ ! -f "$rootca_cert_path" ];then
  echo "generate root cert: $rootca_cert_path."
  openssl x509 -req -days $days -sha1 -extensions v3_ca -signkey $rootca_key_path -in $rootca_csr_path -out $rootca_cert_path
else
  echo "$rootca_cert_path has been generated."
fi

#-----------------------------------------------------------
server_key_path=${root}private/server.key.pem
gen_cert_key_ifnotexist $server_key_path

server_csr_path=${root}private/server.csr
if [ ! -f "$server_csr_path" ];then
  echo "generate server cert csr: $server_csr_path."
  openssl req -new -key $server_key_path -out $server_csr_path -subj "/C=CN/ST=SD/L=JN/O=CSG/OU=CC/CN=gotty"
else
  echo "$server_csr_path has been generated."
fi

server_cert_path=${root}certs/server.cer
ca_srl_path=${root}ca.srl
if [ ! -f "$server_cert_path" ];then
  echo "generate server cert: $server_cert_path."
  openssl x509 -req -days $days -sha1 -extensions v3_req -CA $rootca_cert_path -CAkey $rootca_key_path -CAserial ca.srl -CAcreateserial -in $server_csr_path -out $server_cert_path
else
  echo "$server_cert_path has been generated."
fi

#--------------------------------------------------------------------------

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
  echo "generate cww cert: $cww_cert_path."
  openssl x509 -req -days $days -sha1 -extensions v3_req -CA $rootca_cert_path -CAkey $rootca_key_path -CAserial ca.srl -in $cww_csr_path -out $cww_cert_path
else
  echo "$cww_cert_path has been generated."
fi


echo "download release package"
release_pkg_name=gotty_${VERSION}_linux_amd64.tar.gz
release_pkg_path=./${release_pkg_name}
download_url=${ROOT_URL}v${VERSION}/$release_pkg_name
echo $download_url

if [ ! -f "$release_pkg_path" ];then
  curl -# -C - -L -o $release_pkg_path $download_url
else
  echo "$release_pkg_path has been downloaded."
fi

echo "extract it --------------------------------------------------------------"

tar -xzvf $release_pkg_path -C ./
mv gotty gotty-${VERSION}

gotty_conf_file=gotty.conf.${VERSION}
cp gotty.conf $gotty_conf_file
sed -i "s|tls_crt_file_path|${server_cert_path}|g" $gotty_conf_file
sed -i "s|tls_key_file_path|${server_key_path}|g" $gotty_conf_file
sed -i "s|tls_ca_crt_file_path|${rootca_cert_path}|g" $gotty_conf_file

./gotty-${VERSION} --tls-ca-crt $rootca_cert_path --config $gotty_conf_file bash
