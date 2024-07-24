#!/bin/bash
#
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Check for the required number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: sudo $0 <path_to_dump> <retailstore>"
    echo "Get db with 'ssh root@10.58.0.92 "pg_dump -U postgres -d novounifodb" > backup_file_on_your_local_machine.sql'"
    exit 1
fi

dump_path=$1
retailstore=$2

if [[ ! -z $SUDO_USER ]]; then
    user_home=$(eval echo ~$SUDO_USER)
else
    user_home=$HOME  # This will default to root's home if not invoked with sudo
fi

set -x # debug
postgres='psql -U postgres'

function is_database() {
    echo $1
    $postgres -lqt | cut -d \| -f 1 | grep -wq $1
}

date_now=$(date '+%Y_%m_%d')

if [[ ! -f $dump_path ]]; then
    echo "Error: The provided dump path does not exist."
    exit 1
fi

dumpname="novounifodb_${date_now}"
suffix=1

# While the database exists, keep changing the name
while is_database $dumpname; do
    echo "dumpname ${dumpname} already exists"
    dumpname="novounifodb_${date_now}_${suffix}"
    suffix=$((suffix + 1))
done

# Check for active connections to the database
active_connections=$($postgres -t -c "SELECT COUNT(pid) FROM pg_stat_activity WHERE datname = 'novounifodb';")

if [[ $active_connections -gt 0 ]]; then
    echo "ERROR: There are $active_connections active connections to the 'novounifodb' database."
    echo "Please terminate the connections before proceeding or run the following command:"
    echo "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'novounifodb';"
    exit 1
fi

$postgres -c "ALTER DATABASE novounifodb RENAME TO $dumpname"
$postgres -c "CREATE DATABASE novounifodb"
$postgres -d novounifodb < $dump_path
$postgres -d novounifodb -c "ALTER TABLE POSALIVE ALTER COLUMN version  DROP NOT null;"
$postgres -d novounifodb -c "ALTER TABLE POSALIVE ALTER COLUMN datetimestamp  DROP NOT null;"

# Check if the setup_sqlite.sh script exists
if [[ ! -f "./setup_sqlite.sh" ]]; then
    echo "Error: The script setup_sqlite.sh does not exist in the current directory."
    exit 1
fi

