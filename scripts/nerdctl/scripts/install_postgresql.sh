#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if sudo -u postgres pg_isready; then
    echo "PostgreSQL is running."
    exit 0
fi


# Create the postgres user if it does not exist
if ! id -u postgres > /dev/null 2>&1; then
    useradd -m -s /bin/bash postgres
fi

function check_postgresql_installed() {
    dpkg -l | grep -q postgresql
}

if ! check_postgresql_installed; then
    # Update and install PostgreSQL
    apt-get update
    apt-get install -y postgresql postgresql-contrib screen sudo postgresql-16-pllua postgresql-plpython3-16    
fi


# Initialize PostgreSQL database cluster if it hasn't been initialized
if [ ! -d /var/lib/postgresql/16/main ]; then
    sudo -u postgres /usr/lib/postgresql/16/bin/initdb -D /var/lib/postgresql/16/main
fi

# make sure we can remotely access the postgresql
sed -i "s/^#listen_addresses = .*/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf

cat > /etc/postgresql/16/main/pg_hba.conf <<EOF
local   all             all                                     trust
host    all             all             0.0.0.0/0               trust
host    all             all             ::/0                    trust
EOF

# Start PostgreSQL service
sudo -u postgres pg_ctlcluster 16 main start

# Create a user if it doesn't already exist
#sudo -u postgres psql -c "DO \$\$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin') THEN CREATE USER admin WITH ENCRYPTED PASSWORD 'admin'; END IF; END \$\$;"
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname = 'admin'" | grep -q 1 || sudo -u postgres psql -c "CREATE USER admin WITH ENCRYPTED PASSWORD 'admin';"

# Create a database if it doesn't already exist
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw main; then
    sudo -u postgres psql -c "CREATE DATABASE main;"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE main TO admin;"
    sudo -u postgres psql -c "ALTER ROLE admin WITH SUPERUSER;"
fi

# Create PL/Lua extension
sudo -u postgres psql -d main <<EOF
CREATE EXTENSION IF NOT EXISTS pllua;
EOF


PGPASSWORD=admin psql -h localhost -U admin -d main -c "SELECT 1;" 

# Check if PostgreSQL is running
if sudo -u postgres pg_isready; then
    echo "PostgreSQL is running."
else
    echo "PostgreSQL is not running."
fi
