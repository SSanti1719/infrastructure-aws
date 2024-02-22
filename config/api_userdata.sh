#!/bin/bash
cd /usr/local
sudo curl https://dl.google.com/go/go1.21.6.linux-amd64.tar.gz --output go1.21.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
sudo rm go1.21.6.linux-amd64.tar.gz

sudo tee -a /etc/environment <<EOF
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOCACHE="$HOME/.cache/go-build"
export ZINCSEARCH_IP=${zincsearch_ip}
export ENTRYPOINT_APIREST_ENABLED=${apirest_enabled}
export ENTRYPOINT_APIREST_PORT=${apirest_port}
export ZINCSEARCH_IP=${zincsearch_ip}
export ZINCSEARCH_PORT=${zincsearch_port}
export ZINCSEARCH_INDEX=${zincsearch_index_name}
export ZINC_FIRST_ADMIN_USER=${zincsearch_user}
export ZINC_FIRST_ADMIN_PASSWORD=${zincsearch_pass}
export BASIC_AUTH_USER=${basic_auth_user}
export BASIC_AUTH_PASS=${basic_auth_pass}
export EXTERNAL_USER=${external_auth_user}
export EXTERNAL_PASS=${external_auth_pass}
export JWT_AUTH_SECRET=${jwt_secret}
EOF
source /etc/environment

mkdir /app
cd /app
aws s3 cp s3://${bucket_name}/${zip_file} $PWD
unzip $PWD/${zip_file}
go run ./application