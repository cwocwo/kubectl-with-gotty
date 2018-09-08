#!/bin/bash
# install gotty
source config.sh
echo "download release package"
release_pkg_name=gotty-${VERSION}_linux_amd64.tar.gz
release_pkg_path=./${release_pkg_name}
download_url=${ROOT_URL}${VERSION}/$release_pkg_name

if [ ! -f "$release_pkg_path" ];then
  curl -# -C - -L -o $release_pkg_path $download_url
else
  echo "$release_pkg_path has been downloaded."
fi

echo "extract it --------------------------------------------------------------"

tar -xzvf $release_pkg_path -C ./
mv gotty gotty-${VERSION}
basepath=$(cd `dirname $0`; pwd)
cert_dir=${basepath}/certs/
create_dir_ifnotexist $cert_dir

rootca_key_path=${cert_dir}rootca.key.pem
gen_cert_key_ifnotexist $rootca_key_path

rootca_cert_path=${cert_dir}rootca.cert.pem
gen_cert_ifnotexist $rootca_cert_path $rootca_key_path

gotty_key_path=${cert_dir}gotty.key.pem
gen_cert_key_ifnotexist $gotty_key_path

gotty_csr_path=${cert_dir}gotty.csr.pem
if [ ! -f "$gotty_csr_path" ];then
  openssl req -batch -key $gotty_key_path -new -sha256 -out $gotty_csr_path
else
  echo "$gotty_csr_path has been generated."
fi

gotty_cert_path=${cert_dir}gotty.cert.pem
if [ ! -f "$gotty_cert_path" ];then
  openssl x509 -req -CA $rootca_cert_path -CAkey $gotty_key_path -CAcreateserial -in $gotty_csr_path -out $gotty_cert_path -days 7000
else
  echo "$gotty_cert_path has been generated."
fi

gotty_conf_file=gotty.conf.${VERSION}
cp gotty.conf $gotty_conf_file
sed -i "s|tls_crt_file_path|${gotty_cert_path}|g" $gotty_conf_file
sed -i "s|tls_key_file_path|${gotty_key_path}|g" $gotty_conf_file
sed -i "s|tls_ca_crt_file_path|${rootca_cert_path}|g" $gotty_conf_file

./gotty-${VERSION} bash --tls-ca-crt $rootca_cert_path --config $gotty_conf_file

# openssl req -batch -config openssl.conf -new -x509 -key ./certs/gotty.key.pem -days 7300 -sha256 -out ./certs/gotty.cert.pem -extensions v3_ca


# openssl req -batch -config openssl.conf -new -x509 -newkey rsa:2048 -nodes -keyout /etc/istio/ingressgateway-certs/tls.key -days 3650 -out /etc/istio/ingressgateway-certs/tls.crt
# openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout ~/.gotty.key -out ~/.gotty.crt
