#!/bin/bash

# Enable PostgreSQL module and install necessary packages
dnf module enable postgresql:16 -y
dnf -y install postgresql-server postgresql-jdbc libpq-devel postgresql-odbc

# Check if the database is already initialized
if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
    echo "Initializing PostgreSQL database..."
    postgresql-setup --initdb
else
    echo "PostgreSQL database already initialized. Skipping initialization."
fi

# Start and enable PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Backup the original pg_hba.conf
cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.bak

# Rewrite pg_hba.conf with correct configurations
cat > /var/lib/pgsql/data/pg_hba.conf << EOL
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust
EOL

# Set correct permissions
chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
chmod 600 /var/lib/pgsql/data/pg_hba.conf

# Restart PostgreSQL
systemctl restart postgresql

echo "PostgreSQL setup complete. You should now be able to connect using 'psql -U postgres'"
