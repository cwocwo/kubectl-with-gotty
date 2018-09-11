#!/bin/bash
source config.sh

./gen-root-and-server-cert.sh

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

echo "./gotty-${VERSION} --tls-ca-crt $rootca_cert_path --config $gotty_conf_file bash"
./gotty-${VERSION} --tls-ca-crt $rootca_cert_path --config $gotty_conf_file bash
