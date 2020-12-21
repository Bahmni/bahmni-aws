#!/bin/bash
set -e
container_name=$container_name
sudo rsync -abv --remove-source-files  /etc/bahmni-certs /${container_name}/
if [ -f /etc/my.cnf ]; then
    if [ -n "$(ls -a /${container_name}/mysql)" ]; then
        echo "directory exists and already mysql sync completed"
    else
        sudo mkdir -p /${container_name}/mysql && sudo chown -R mysql:mysql /${container_name}/mysql
        sudo rsync -avr -o -g /var/lib/mysql /${container_name}
    fi
    sudo sed -i "s|datadir=/var/lib/mysql|datadir=/${container_name}/mysql|g" /etc/my.cnf
    sudo systemctl restart mysqld
else
   echo "File /etc/my.cnf does not exist."
fi

if [ -f /var/lib/pgsql/.bash_profile ]; then
    sudo mkdir -p /${container_name}/pgsql/9.6/data && sudo chown -R postgres:postgres /${container_name}/pgsql
    sudo sed -i "s|PGDATA=/var/lib/pgsql/9.6/data|PGDATA=/${container_name}/pgsql/9.6/data|g" /var/lib/pgsql/.bash_profile
    export PGDATA
    sudo systemctl restart postgresql-9.6
else
   echo "File /var/lib/pgsql/.bash_profile does not exist."
fi

if [ -n "$(ls -A /${container_name}/pgsql)" ]; then
    echo "Directory exists and Already Postgres sync completed"
else
    sudo rsync -avr -o -g /var/lib/pgsql /${container_name}
    sudo systemctl restart postgresql-9.6
fi

if [ -d /home/bahmni ]; then
   sudo bahmni -ilocal stop
   sudo rsync -avr -o -g /home/bahmni /${container_name}
   ln -s /${container_name}/bahmni /home/bahmni && chown -h bahmni:bahmni /home/bahmni
   sudo bahmni -ilocal start
else
   echo "Directory /home/bahmni does not exists."
fi

if [ -f /etc/odoo.conf ]; then
# sudo rm -rf /var/run/odoo/odoo-server.pid
    sudo systemctl restart odoo
else
   echo "Openerp not installed."
fi
