#!/bin/bash

container_id=$(docker ps -q -f name=voinetwork_algod)
if [ -z "${container_id}" ]; then
    echo "AVM container is not running. Please start it first."
    exit 1
fi

set_telemetry_name() {
  if [[ -z ${VOINETWORK_TELEMETRY_NAME} ]]; then
    echo "Voi uses node telemetry to improve the network, and reward people with Voi based on telemetry participation."
    echo ""
    echo "To set a custom telemetry name, set the VOINETWORK_TELEMETRY_NAME environment variable before running this script."
    echo "Example: export VOINETWORK_TELEMETRY_NAME='my_custom_name'"
    echo ""
    echo "If you do set a name we will prefix the name with 'VOI:' to make it clear that it is running this package."
    echo "To set your own Voi docker node name enter it now, to skip telemetry gathering type 'continue' below."
    read -p "Telemetry name: " VOINETWORK_TELEMETRY_NAME
    if [[ "${VOINETWORK_TELEMETRY_NAME}" == "continue" ]]; then
      unset VOINETWORK_TELEMETRY_NAME
      return
    else
      VOINETWORK_TELEMETRY_NAME="VOI:$VOINETWORK_TELEMETRY_NAME"
    fi
  fi
}

set_telemetry_name

bash -c "export VOINETWORK_TELEMETRY_NAME=\"${VOINETWORK_TELEMETRY_NAME}\" && docker stack deploy -c ../docker-swarm/compose.yml voinetwork"

