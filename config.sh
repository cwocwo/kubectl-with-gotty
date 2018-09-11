ROOT_URL="https://github.com/yudai/gotty/releases/download/"
VERSION="2.0.0-alpha.3"

function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir -p $1
  else
    echo "$1 already exists."
  fi
}

function gen_cert_key_ifnotexist {
  if [ ! -f "$1" ];then
    echo "generate cert key: $1."
    openssl genrsa -out $1 4096
  else
    echo "$1 has been generated."
  fi
}

function gen_cert_ifnotexist {
  if [ ! -f "$1" ];then
    echo "generate cert: $1."
    openssl req -batch -config openssl.conf -new -x509 -key $2 -days 7300 -sha256 -extensions v3_ca -out $1
  else
    echo "$1 has been generated."
  fi
}

function gen_cert_csr_ifnotexist {
  if [ ! -f "$1" ];then
    echo "generate cert csr: openssl req -batch -key $2 -new -sha256 -out $1 -config $3"
     
    openssl req -batch -key $2 -new -sha256 -out $1 -config $3
  else
    echo "$1 has been generated."
  fi
}

# 1 cert path  2.csr path  3.root key path 4.root ca path
function gen_cert_use_csr {
  if [ ! -f "$1" ];then
    # openssl x509 -req -CA $rootca_cert_path -CAkey $gotty_key_path -CAcreateserial -in $gotty_csr_path -out $gotty_cert_path -days 7000
    echo "generate cert use csr:  openssl x509 -req -CA $4 -CAkey $3 -CAcreateserial -CAserial ca.srl -in $2 -out $1 -days 7000"
    openssl x509 -req -CA $4 -CAkey $3 -CAcreateserial -in $2 -out $1 -days 7000
  else
    echo "$1 has been generated."
  fi
}

days=3650
#root=/etc/pki/CA/
basepath=$(cd `dirname $0`; pwd)

root_dir=${basepath}/tls/
create_dir_ifnotexist $root_dir

private_key_dir=${root_dir}private
create_dir_ifnotexist $private_key_dir

certs_dir=${root_dir}certs
create_dir_ifnotexist $certs_dir

rootca_key_path=${private_key_dir}/rootca.key.pem
rootca_cert_path=${certs_dir}/rootca.cer

server_key_path=${private_key_dir}/server.key.pem
server_cert_path=${certs_dir}/server.cer

clients_dir=${root_dir}clients
create_dir_ifnotexist $clients_dir
