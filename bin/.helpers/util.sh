#!/bin/bash

function util_get_profile() {
    local voi_home="${HOME}/voi"
    if [ -f "${voi_home}/.profile" ]; then
      source "${voi_home}/.profile"
    else
      util_abort "Profile not found. Exiting the program."
    fi

    if [ -z "${VOINETWORK_PROFILE}" ]; then
      util_abort "Profile not found. Exiting the program."
    fi
}

function util_get_container_id() {
  if [[ ${VOINETWORK_PROFILE} == "relay" ]]; then
    CONTAINER_ID=$(docker ps -q -f name=voinetwork_relay)
  elif [[ ${VOINETWORK_PROFILE} == "developer" ]]; then
    CONTAINER_ID=$(docker ps -q -f name=voinetwork_developer)
  elif [[ ${VOINETWORK_PROFILE} == "participation" ]]; then
    CONTAINER_ID=$(docker ps -q -f name=voinetwork_algod)
  else
    util_abort "Invalid profile. Exiting the program."
  fi
}

function util_abort() {
  echo "$1"
  exit 1
}

function util_validate_running_container() {
  if [ -z "${CONTAINER_ID}" ]; then
      echo "AVM container is not running. Please start it first."
      exit 1
  fi
}

function util_update_profile_setting() {
  local setting_name="$1"
  local new_value="$2"
  local profile_file="${HOME}/voi/.profile"

  if grep -q "^export ${setting_name}=" "$profile_file"; then
    # Update the existing setting
    sed -i "s/^export ${setting_name}=.*/export ${setting_name}=${new_value}/" "$profile_file"
  else
    # Add the new setting if it doesn't exist
    echo "export ${setting_name}=${new_value}" >> "$profile_file"
  fi
}

## TODO: Add support for multiple docker files, such as when using notification services
function util_start_stack() {
  local composeFile
  if [[ ${VOINETWORK_PROFILE} == "relay" ]]; then
    composeFile="${HOME}/voi/docker/relay.yml"
  elif [[ ${VOINETWORK_PROFILE} == "developer" ]]; then
    composeFile="${HOME}/voi/docker/developer.yml"
  else
    composeFile="${HOME}/voi/docker/compose.yml"
  fi
  bash -c "source ${HOME}/voi/.profile && docker stack deploy -c ${composeFile} voinetwork"
}

function util_validate_supported_node_type() {
  local valid_profiles=("$@")
  local is_valid=false

  for profile in "${valid_profiles[@]}"; do
    if [[ ${VOINETWORK_PROFILE} == "$profile" ]]; then
      is_valid=true
      break
    fi
  done

  if [ "$is_valid" = false ]; then
    util_abort "This operation is only supported for the following profiles: ${valid_profiles[*]}. Exiting the program."
  fi
}

util_get_profile
util_get_container_id
