#!/bin/bash
# install gotty
source config.sh
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
gen_cert_csr_ifnotexist $gotty_csr_path $gotty_key_path openssl-csr-req.conf

gotty_cert_path=${cert_dir}gotty.cert.pem
gen_cert_use_csr $gotty_cert_path $gotty_csr_path $rootca_key_path $rootca_cert_path

gotty_conf_file=gotty.conf.${VERSION}
cp gotty.conf $gotty_conf_file
sed -i "s|tls_crt_file_path|${gotty_cert_path}|g" $gotty_conf_file
sed -i "s|tls_key_file_path|${gotty_key_path}|g" $gotty_conf_file
sed -i "s|tls_ca_crt_file_path|${rootca_cert_path}|g" $gotty_conf_file

./gotty-${VERSION} --tls-ca-crt $rootca_cert_path --config $gotty_conf_file bash

# openssl req -batch -config openssl.conf -new -x509 -key ./certs/gotty.key.pem -days 7300 -sha256 -out ./certs/gotty.cert.pem -extensions v3_ca


# openssl req -batch -config openssl.conf -new -x509 -newkey rsa:2048 -nodes -keyout /etc/istio/ingressgateway-certs/tls.key -days 3650 -out /etc/istio/ingressgateway-certs/tls.crt
# openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout ~/.gotty.key -out ~/.gotty.crt
