#!/bin/bash
set -e
container_name=$container_name
curl https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm  --output /opt/pgdg-redhat-repo-latest.noarch.rpm
bahmni -ilocal install
aws_secret_key=$1
aws_access_key=$2

if [[ -f "/${container_name}/letsencrypt-certs/cert.crt" && -f "/${container_name}/letsencrypt-certs/chained.pem" && -f "/${container_name}/letsencrypt-certs/domain.key" ]] ;
then
	echo "Using certs from specified locations" ;
    rm -rf /etc/bahmni-certs/* ;
    ln -s /${container_name}/letsencrypt-certs/cert.crt /etc/bahmni-certs/cert.crt;
    ln -s /${container_name}/letsencrypt-certs/chained.pem /etc/bahmni-certs/chained.pem;
    ln -s /${container_name}/letsencrypt-certs/domain.key /etc/bahmni-certs/domain.key;
else
	echo "Could not find certs to use" ;
fi
bahmni -ilocal start ;
systemctl restart bahmni-lab ;
