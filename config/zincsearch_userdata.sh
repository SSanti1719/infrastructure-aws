#!/bin/bash
sudo tee -a /etc/environment <<EOF
export ZINC_FIRST_ADMIN_USER=${zincsearch_user}
export ZINC_FIRST_ADMIN_PASSWORD=${zincsearch_pass}
export ZINC_SERVER_PORT=${zincsearch_port}
EOF
source /etc/environment

sudo mkdir /zincsearch
cd /zincsearch
sudo aws s3 cp s3://${bucket_name}/${zip_file} $PWD
sudo unzip $PWD/${zip_file}
sudo mkdir data
sudo chmod +x zincsearch
sudo ./zincsearch