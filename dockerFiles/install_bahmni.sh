#!/bin/bash
set -e
container_name=$container_name
yum -y install https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/19.fc30/x86_64/zlib-1.2.11-19.fc30.x86_64.rpm
bahmni -ilocal install
aws_secret_key=$1
aws_access_key=$2

if [[ -f "/${container_name}/letsencrypt/cert.crt" && -f "/${container_name}/letsencrypt/chained.pem" && -f "/${container_name}/letsencrypt/domain.key" ]] && openssl x509 -checkend 86400 -noout -in "/${container_name}/letsencrypt/chained.pem" ;
then
	echo "inside if" ;
    rm -rf /etc/bahmni-certs/* ;
    ln -s /${container_name}/letsencrypt-certs/cert.crt /etc/bahmni-certs/cert;
    ln -s /${container_name}/letsencrypt-certs/chained.pem /etc/bahmni-certs/chained.pem;
    ln -s /${container_name}/letsencrypt-certs/domain.key /etc/bahmni-certs/domain.key;
else
	echo "inside else" ;
	sudo rm -rf /opt/letsencrypt ;
	sudo mkdir -p /opt/letsencrypt ;
    sudo git clone https://github.com/Bahmni/letsencrypt.git /opt/letsencrypt ;
    cd "/opt/letsencrypt" ;
    ansible-playbook -i infra_inventory letsencrypt.yml --extra-vars="aws_access_key=$aws_access_key" --extra-vars="aws_secret_key=$aws_secret_key" --extra-vars="container_name=$container_name" -vvv ;
    rm -rf /etc/bahmni-certs/* ;
    sudo ln -s /${container_name}/letsencrypt-certs/cert.crt /etc/bahmni-certs/cert.crt ;
    sudo ln -s /${container_name}/letsencrypt-certs/chained.pem /etc/bahmni-certs/chained.pem ;
    sudo ln -s /${container_name}/letsencrypt-certs/domain.key /etc/bahmni-certs/domain.key ;
fi
sudo /${container_name}/db_service.sh ;
bahmni -ilocal start ;
service bahmni-lab restart ;
