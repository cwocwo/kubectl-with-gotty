ROOT_URL="https://github.com/yudai/gotty/releases/download/"
VERSION="v2.0.0-alpha.3"

function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir -p $1
  else
    echo "$1 already exists."
  fi
}

function gen_cert_key_ifnotexist {
  if [ ! -f "$1" ];then
    openssl genrsa -out $1 4096
  else
    echo "$1 has been generated."
  fi
}

function gen_cert_ifnotexist {
  if [ ! -f "$1" ];then
    openssl req -batch -config openssl.conf -new -x509 -key $2 -days 7300 -sha256 -out $1
  else
    echo "$1 has been generated."
  fi
}
