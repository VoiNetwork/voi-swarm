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

util_get_profile
util_get_container_id
