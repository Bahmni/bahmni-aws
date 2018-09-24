#!/bin/bash

set -eu
set -x ; debugging
cd ~
echo "$PWD"

if [ ! -d ".docker/" ]
then
    echo "Directory ./docker/ does not exist"
    echo "Creating the directory"
    mkdir .docker
fi

cd .docker/
echo "type in your certificate password"
read -p '>' -s PASSWORD

echo "Key in server name that you’ll use to connect to the Docker-server"
read -p '>' SERVER

openssl genrsa -aes256 -passout pass:$PASSWORD -out ca-key.pem 2048
openssl req -new -x509 -days 365 -key ca-key.pem -passin pass:$PASSWORD -sha256 -out ca.pem -subj "/C=TR/ST=./L=./O=./CN=$SERVER"
openssl genrsa -out server-key.pem 2048
openssl req -new -key server-key.pem -subj "/CN=$SERVER"  -out server.csr
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out server-cert.pem
openssl genrsa -out key.pem 2048
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
sh -c 'echo "extendedKeyUsage = clientAuth" > extfile.cnf'
openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out cert.pem -extfile extfile.cnf
echo "Removing unnecessary files i.e. client.csr extfile.cnf server.csr"
rm ca.srl client.csr extfile.cnf server.csr
echo "Changing the permissions to readonly by root for the server files."
chmod 0400 ca-key.pem key.pem server-key.pem
echo "Changing the permissions of the client files to read-only by everyone"
chmod 0444 ca.pem server-cert.pem cert.pem

mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/override.conf << "EOF"
[Service]
     ExecStart=
     ExecStart=/usr/bin/dockerd -D -H unix:///var/run/docker.sock --tlsverify  --tlscert=~/.docker/server-cert.pem --tlscacert=~/.docker/ca.pem --tlskey=~/.docker/server-key.pem -H tcp://0.0.0.0:2376

EOF
sudo systemctl daemon-reload
sudo systemctl restart docker