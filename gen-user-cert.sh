#!/bin/bash

source config.sh

username=$1
basepath=$(cd `dirname $0`; pwd)
cert_dir=${basepath}/certs/
user_cert_dir=${basepath}/certs/user
create_dir_ifnotexist $user_cert_dir

rootca_key_path=${cert_dir}rootca.key.pem

user_cert_key_path=$user_cert_dir/${username}.key.pem
gen_cert_key_ifnotexist $user_cert_key_path

user_cert_csr_path=$user_cert_dir/${username}.csr.pem
gen_cert_csr_ifnotexist $user_cert_csr_path $user_cert_key_path openssl-csr-req.conf

user_cert_path=$user_cert_dir/${username}.cert.pem
gen_cert_use_csr $user_cert_path $user_cert_csr_path ${cert_dir}rootca.key.pem ${cert_dir}rootca.cert.pem

openssl pkcs12 -export -clcerts -in $user_cert_path -inkey $user_cert_key_path -out client.p12
