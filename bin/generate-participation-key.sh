#!/bin/bash

container_id=$(docker ps -q -f name=voinetwork_algod)
if [ -z "${container_id}" ]; then
    echo "AVM container is not running. Please start it first."
    exit 1
fi

if [ -z "$1" ]; then
    echo "Please provide an account address as a parameter."
    echo "Example: generate-participation-key.sh <account_address>"
    exit 1
fi

docker exec -e account_addr="$1" -it "${container_id}" bash -c 'start=$(goal node status | grep "Last committed block:" | cut -d\  -f4) && duration=${duration:-2000000} && end=$((start + duration)) && goal account addpartkey -a ${account_addr} --roundFirstValid $start --roundLastValid $end'
