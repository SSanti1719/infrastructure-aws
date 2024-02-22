#!/bin/bash
cd /usr/local
sudo curl https://dl.google.com/go/go1.21.6.linux-amd64.tar.gz --output go1.21.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
sudo rm go1.21.6.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOCACHE="$HOME/.cache/go-build"


sudo tee -a /etc/environment <<EOF
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOCACHE="$HOME/.cache/go-build"
export ZINCSEARCH_IP=${zincsearch_ip}
export ZINCSEARCH_PORT=${zincsearch_port}
export ZINCSEARCH_INDEX=${zincsearch_index_name}
export ZINCSEARCH_FILES_DIR=${zincsearch_files_dir}
export ZINC_FIRST_ADMIN_USER=${zincsearch_user}
export ZINC_FIRST_ADMIN_PASSWORD=${zincsearch_pass}
EOF
source /etc/environment

mkdir /app
cd /app
aws s3 cp s3://${bucket_name}/${zip_file} $PWD
unzip $PWD/${zip_file}
sudo mkdir ${zincsearch_files_dir}
cd ${zincsearch_files_dir}
aws s3 cp s3://${bucket_name}/${data_file} $PWD
unzip $PWD/${data_file}
cd /app
go run .