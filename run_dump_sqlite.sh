#!/bin/bash

postgres='psql -U postgres'

function does_retailstore_exist() {
    local count
    count=$($postgres -t -d novounifodb -c "SELECT COUNT(*) FROM retailstore WHERE retailstoreid= $1;")
    if [[ $count -eq 0 ]]; then
        return 1
    fi
    return 0
}

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Check for the required argument
if [ "$#" -ne 1 ]; then
    echo "Usage: sudo $0 <retailstore>"
    exit 1
fi

retailstore=$1

if ! does_retailstore_exist $retailstore; then
    echo "ERROR: The retailstore ID $retailstore does not exist in the 'retailstore' table."
    exit 1
fi

if [[ ! -z $SUDO_USER ]]; then
    user_home=$(eval echo ~$SUDO_USER)
else
    user_home=$HOME  # This will default to root's home if not invoked with sudo
fi

sudo mkdir -p /tlanBiS/loadinfo/our_output/fusion/data/outbound/retailstores/${retailstore}
sudo mkdir -p /tlanBiS/loadinfo/our_output/fusion/data/outbound/${retailstore}


migration_tool_path="/home/giulianof/Documents/repositories/fusion_product/fusion-system-IV/fusion-configuration-assets/tools/database-migration-mint20/"
#migration_tool_path="/home/giulianof/Documents/repositories/fusion/fusion-system-IV/fusion-configuration-assets/tools/database-migration/"

if [[ ! -d $migration_tool_path ]]; then
    echo "ERROR: Directory $migration_tool_path does not exist."
    exit 1
fi

cd $migration_tool_path
sudo rm -rf /tlanBiS/loadinfo/our_output/fusion/data/outbound/${retailstore}
sudo ./export_db.sh -r=${retailstore} -sq='sequel/bin/sequel' -ip=127.0.0.1
sudo rm -rf /tlanBiS/loadinfo/our_output/fusion/data/outbound/retailstores/${retailstore}
sudo cp -r /tlanBiS/loadinfo/our_output/fusion/data/outbound/${retailstore} /tlanBiS/loadinfo/our_output/fusion/data/outbound/retailstores/${retailstore}
sudo rm -fr /opt/fusion/running/data/inbound/retailstores/${retailstore}/*
sudo rm -fr /opt/fusion/running/data/db/*

$postgres -d novounifodb -c "DELETE FROM POSALIVE"

sudo rm -f "/tlanBiS/loadinfo/our_output/fusion/data/outbound/retailstores/${retailstore}/fusion-wks-local-db.db.timestamp"
sudo echo "19911130124500" | sudo tee -a  "/tlanBiS/loadinfo/our_output/fusion/data/outbound/retailstores/${retailstore}/fusion-wks-local-db.db.timestamp"

