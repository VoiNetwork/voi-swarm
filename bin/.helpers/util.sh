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
  case ${VOINETWORK_PROFILE} in
    "relay")
      CONTAINER_ID=$(docker ps -q -f name=voinetwork_relay)
      ;;
    "developer")
      CONTAINER_ID=$(docker ps -q -f name=voinetwork_developer)
      ;;
    "archiver")
      CONTAINER_ID=$(docker ps -q -f name=voinetwork_archiver)
      ;;
    "participation")
      CONTAINER_ID=$(docker ps -q -f name=voinetwork_algod)
      ;;
    *)
      util_abort "Invalid profile. Exiting the program."
      ;;
  esac
}

function util_abort() {
  echo "$1"
  exit 1
}

# Proposer rewards (consensus v40): accounts are only paid when registered online with a keyreg fee of
# at least 2 Voi, and while their balance is between 30,000 and 70,000,000 Voi. Amounts are in microVoi.
PROPOSER_REWARDS_KEYREG_FEE=2000000
PROPOSER_REWARDS_MIN_BALANCE=30000000000
PROPOSER_REWARDS_MAX_BALANCE=70000000000000

function util_get_account_dump() {
  docker exec -e account_addr="$1" "${CONTAINER_ID}" bash -c '/node/bin/goal account dump -a "${account_addr}"'
}

function util_has_proposer_rewards_balance() {
  local balance=$1
  [[ ${balance} -ge ${PROPOSER_REWARDS_MIN_BALANCE} && ${balance} -le ${PROPOSER_REWARDS_MAX_BALANCE} ]]
}

function util_print_proposer_rewards_status() {
  local account=$1
  local account_info=$2
  local balance
  balance=$(jq -r '.algo // 0' <<< "${account_info}")

  if [[ $(jq -r '.ie // false' <<< "${account_info}") == "true" ]]; then
    if util_has_proposer_rewards_balance "${balance}"; then
      echo "Your account is eligible for proposer rewards."
    else
      echo "Your account is opted in to proposer rewards, but only balances between 30,000 and 70,000,000 Voi receive them."
    fi
  elif util_has_proposer_rewards_balance "${balance}"; then
    echo "Your account is not eligible for proposer rewards. To opt in, use ${HOME}/voi/bin/enable-rewards ${account}"
  else
    echo "Your account is not eligible for proposer rewards. These require a balance between 30,000 and 70,000,000 Voi."
  fi
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
  case ${VOINETWORK_PROFILE} in
    "relay")
      composeFile="${HOME}/voi/docker/relay.yml"
      ;;
    "developer")
      composeFile="${HOME}/voi/docker/developer.yml"
      ;;
    "archiver")
      composeFile="${HOME}/voi/docker/archiver.yml"
      ;;
    "participation")
      composeFile="${HOME}/voi/docker/compose.yml"
      ;;
    *)
      util_abort "Invalid profile. Exiting the program."
      ;;
  esac
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
