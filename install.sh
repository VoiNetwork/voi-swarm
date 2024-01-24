#!/bin/bash

account_addr=""
docker_swarm_started=0
voi_home="${HOME}/voi"
headless_install=0
is_root=0
skip_account_setup=0

execute_sudo() {
  if [ ${is_root} -eq 1 ]; then
    bash -c "$1"
  else
    sudo bash -c "$1"
  fi
}

abort() {
  if [ ${docker_swarm_started} -eq 1 ]; then
    echo "Shutting down docker swarm"
    echo ""
    execute_sudo 'docker swarm leave --force'
  fi
  echo "$1"
  exit 1
}

execute_docker_command_internal() {
  local interactive=$1
  local command=$2
  local options=""

  if [ "$interactive" = "yes" ]; then
    options="-it"
  fi

  execute_sudo "docker exec -e account_addr=${account_addr} ${options} \"${container_id}\" bash -c \"${command}\""
}

execute_interactive_docker_command() {
  local retries=0
  while [ $retries -lt 10 ]; do
    execute_docker_command_internal "yes" "$1"
    local exit_code=$?
    if [ ${exit_code} -eq 130 ]; then
      exit ${exit_code} >&2
    fi
    if [ ${exit_code} -ne 0 ]; then
      echo "Error executing command. Please try again or press CTRL-C to exit."
      ((retries++))
    else
      break
    fi
  done

  if [ $retries -eq 10 ]; then
    abort "Command failed after 10 attempts. Exiting the program."
  fi
}

execute_docker_command() {
  execute_docker_command_internal "no" "$1"
}

start_docker_swarm() {
  local docker_swarm
  docker_swarm=$(execute_sudo 'docker info | grep Swarm | cut -d\  -f3')
  if [ "${docker_swarm}" != "active" ]; then
    command="docker swarm init"

    if [[ -n ${VOINETWORK_DOCKER_SWARM_INIT_SETTINGS} ]]; then
      command+=" ${VOINETWORK_DOCKER_SWARM_INIT_SETTINGS}"
    fi

    execute_sudo "$command"

    if [ $? -ne 0 ]; then
      docker_swarm_instructions
    fi

    docker_swarm_started=1
  fi
}

wait_for_stack_to_be_ready() {
  while true; do
    service_info=$(execute_sudo 'docker stack ps voinetwork --format json' | grep 'voinetwork_algod')
    service_running=false

    while read -r line; do
      current_state=$(echo "${line}" | jq -r '.CurrentState')
      desired_state=$(echo "${line}" | jq -r '.DesiredState')

      if [[ ${current_state} == Running* ]] && [[ ${desired_state} == "Running" ]]; then
        service_running=true
        break
      fi
    done < <(echo "${service_info}")

    if [[ ${service_running} == true ]]; then
      break
    else
      echo "Waiting for stack to be ready..."
      sleep 2
    fi
  done

  display_banner "Stack is ready!"
}

verify_node_is_running() {
  local retries=0
  local max_retries=5

  while [ $retries -lt $max_retries ]; do
    container_id=$(execute_sudo "docker ps -q -f name=voinetwork_algod")
    if [ -n "$container_id" ]; then
      execute_sudo "docker exec -e account_addr=${account_addr} ${container_id} bash -c \"goal node status\""
      local exit_code=$?
      if [ $exit_code -eq 0 ]; then
        break
      fi
    fi

    echo "Error connecting to node. Retrying in 10 seconds..."
    sleep 10
    ((retries++))
  done

  if [ $retries -eq $max_retries ]; then
    abort "Error connecting to node after $max_retries attempts. Exiting the program."
  fi
}

get_current_net_round() {
  local retries=0
  local max_retries=5

  while [ $retries -lt $max_retries ]; do
    current_net_round=$(curl -s https://testnet-api.voi.nodly.io/v2/status | jq -r '.["last-round"]' )
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -n "$current_net_round" ]; then
      break
    fi

    echo "Error fetching network status. Retrying in 5 seconds..."
    sleep 5
    ((retries++))
  done

  if [ $retries -eq $max_retries ]; then
    abort "Error fetching network status after $max_retries attempts. Please check your internet connection and try again."
  fi
}

get_node_status() {
    current_node_round=$(execute_docker_command 'goal node lastround | head -n 1')
    get_current_net_round
    current_node_round=${current_node_round//[!0-9]/}
}

catchup_node() {
  display_banner "Catching up with the network... This might take some time, and numbers might briefly increase"
  get_node_status
  while [ "${current_node_round}" -lt "${current_net_round}" ]; do
    rounds_to_go=$((${current_net_round}-${current_node_round}))
    if [ ${rounds_to_go} -gt 1 ]; then
      printf "\rWaiting for catchup: %d blocks to go                     " ${rounds_to_go}
    else
      printf "\rWaiting for catchup: One more block to go!                                           "
    fi
    get_node_status
    sleep 5
  done
  display_banner "Caught up with the network!"
}

create_wallet() {
  if [[ $(execute_docker_command "goal wallet list | wc -l") -eq 1 ]]; then
    echo "Let's create a new wallet for you. Please provide a password for security."
    echo "Seeing the wallet's mnemonic is optional. Any Voi will be linked with the account we'll create or import after wallet creation."

    execute_interactive_docker_command "goal wallet new voi"
  else
    echo "Wallet already exists. Skipping wallet creation."
  fi
}

get_address_balance() {
    balance=$(execute_docker_command "goal account balance -a ${account_addr}")
    balance=${balance//[!0-9]/}
}

busy_wait_until_balance_is_1_voi() {
  display_banner "Waiting for balance (account: ${account_addr}) to be 1 Voi"
  get_address_balance
  while [ "${balance}" -lt "1000000" ]; do
    echo "Waiting for balance to be 1 Voi at minimum"
    get_address_balance
    sleep 10
  done
  display_banner "Account has balance of 1 Voi or greater!"
}

get_account_info() {
  allow_one_account=$1

  if execute_sudo 'test ! -f "/var/lib/voi/algod/data/voitest-v1/accountList.json"'; then
    abort "Account list not found. Exiting the program."
  fi

  accounts_json=$(execute_sudo 'cat /var/lib/voi/algod/data/voitest-v1/accountList.json')
  number_of_accounts=$(echo "${accounts_json}" | jq '.Accounts | length')

  if [ "$number_of_accounts" -gt 1 ]; then
    echo "More than one account found in wallet. Skipping account creation."
    skip_account_setup=1
    return 1
  elif [ "$number_of_accounts" -eq 1 ] && [ "$allow_one_account" != "true" ]; then
    echo "One account found in wallet. Skipping account creation."
    skip_account_setup=1
    return 1
  fi

  account_address=$(echo $accounts_json | jq '.Accounts | keys[0]')
  echo "${account_address}"
}

check_if_account_exists() {
  allow_one_account_override="$1"
  get_account_info "$allow_one_account_override" > /dev/null
}

get_account_address() {
  account_address=$(get_account_info true)
  account_address=${account_address//\"/}

  if [[ ! "${account_address}" =~ ^[A-Za-z0-9]{58}$ ]]; then
    abort "Invalid account address: \"${account_address}\""
  fi

  account_addr=$account_address
}

generate_participation_key() {
  start_block=$(execute_interactive_docker_command "goal node status" | grep "Last committed block" | cut -d\  -f4 | tr -d '\r')
  end_block=$((${start_block} + 2000000))
  execute_interactive_docker_command "goal account addpartkey -a ${account_addr} --roundFirstValid ${start_block} --roundLastValid ${end_block}"
}

display_banner() {
  echo
  echo "********************************************************************************"
  echo "* $1"
  echo "********************************************************************************"
  echo
}

docker_swarm_instructions() {
  echo ""
  echo "Error initializing Docker Swarm."
  echo ""
  echo "Set VOINETWORK_DOCKER_SWARM_INIT_SETTINGS to the settings you want to use to initialize Docker Swarm and try again."
  echo "Example: export VOINETWORK_DOCKER_SWARM_INIT_SETTINGS='--advertise-addr 10.0.0.1'"
  abort "Exiting the program."
}

joined_network_instructions() {
  echo "IMPORTANT: Utility scripts for managing your setup is available in ${voi_home}/bin"

  if [[ ${is_root} -eq 0 ]]; then
    echo "Ensure you restart your shell to use them, or type 'newgrp docker' in your existing shell."
  fi

  echo ""
  echo "To see a list of useful commands reference:"
  echo " - Install README.md: https://github.com/VoiNetwork/docker-swarm/blob/main/README.md"
  echo " - Docker Swarm documentation: https://docs.docker.com/engine/swarm/"
  echo ""
  if [[ ${skip_account_setup} -eq 1 ]]; then
    echo "We skipped creation of a new account as we detected you have a wallet with an account already."
    echo ""
    echo "To see network participation status use ${HOME}/voi/bin/get-participation-status <account_address>"
    echo "To go online use ${HOME}/voi/bin/go-online <account_address>"
  fi
}

add_docker_groups() {
  if [[ is_root -eq 0 ]]; then
    if [ ! "$(getent group docker)"  ]; then
      execute_sudo "groupadd docker"
    fi
    execute_sudo "usermod -aG docker ${USER}"
  fi
}

set_telemetry_name() {
  if [[ ${headless_install} -eq 1 ]]; then
    ## Allow headless install to skip telemetry name setup in case people bring their own wallets / use CI
    return
  fi
  if [[ -z ${VOINETWORK_TELEMETRY_NAME} ]]; then
    echo "Voi uses telemetry to make the network better and reward users with Voi if participating."
    echo ""
    echo "Type your telemetry name below. We'll add 'VOI:' at the start to show you're using this package."
    echo ""
    echo "To use a custom name, set the VOINETWORK_TELEMETRY_NAME variable before running this script."
    echo "Example: export VOINETWORK_TELEMETRY_NAME='my_custom_name'"
    echo ""
    echo "To skip telemetry sharing, type 'continue' below."
    read -p "Telemetry name: " VOINETWORK_TELEMETRY_NAME
    if [[ "${VOINETWORK_TELEMETRY_NAME}" == "continue" ]]; then
      unset VOINETWORK_TELEMETRY_NAME
      return
    else
      VOINETWORK_TELEMETRY_NAME="VOI:$VOINETWORK_TELEMETRY_NAME"
    fi
  fi
}

if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

if [ "$(id -u)" -eq 0 ]; then
  is_root=1
fi

# Get Linux OS distribution
if [ -f /etc/os-release ]; then
  . /etc/os-release
  operating_system_distribution="${ID}"
else
  abort "This script is only meant to be run on Debian or Ubuntu."
fi

if [[ ! (${operating_system_distribution} == "ubuntu" || ${operating_system_distribution} == "debian") ]]; then
  echo "Detected operating system: ${operating_system_distribution}"
  abort "This script is only meant to be run on Debian or Ubuntu."
fi

if [[ -n ${VOINETWORK_SKIP_WALLET_SETUP} && ${VOINETWORK_SKIP_WALLET_SETUP} -eq 1 ]] || [[ -n $VOINETWORK_HEADLESS_INSTALL ]]; then
  headless_install=1
fi

set_telemetry_name

display_banner "Installing Docker"

execute_sudo "apt-get update"
execute_sudo "apt-get install -y ca-certificates curl gnupg"
execute_sudo "install -m 0755 -d /etc/apt/keyrings"

case ${operating_system_distribution} in
  "ubuntu")
    execute_sudo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg"
    execute_sudo "chmod a+r /etc/apt/keyrings/docker.gpg"
    execute_sudo "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" > /etc/apt/sources.list.d/docker.list"
    ;;
  "debian")
    execute_sudo "curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg"
    execute_sudo "chmod a+r /etc/apt/keyrings/docker.gpg"
    execute_sudo "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" > /etc/apt/sources.list.d/docker.list"
    ;;
esac

execute_sudo "apt-get update"

execute_sudo "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

add_docker_groups

if [ -z "$(docker --version | grep 'Docker version')" ]; then
  abort "Docker installation failed."
fi

## Install script dependencies
execute_sudo "apt-get install -y jq"

display_banner "Starting stack"

start_docker_swarm

if [ ! -e /var/lib/voi/algod/data ]; then
  execute_sudo "mkdir -p /var/lib/voi/algod/data"
fi
mkdir -p "${voi_home}"

display_banner "Fetching the latest Voi Network updates and scripts."
curl -L https://api.github.com/repos/VoiNetwork/docker-swarm/tarball/main --output "${voi_home}"/docker-swarm.tar.gz
tar -xzf "${voi_home}"/docker-swarm.tar.gz -C "${voi_home}" --strip-components=1
rm "${voi_home}"/docker-swarm.tar.gz

execute_sudo "env VOINETWORK_TELEMETRY_NAME=$VOINETWORK_TELEMETRY_NAME docker stack deploy -c ${voi_home}/docker-swarm/compose.yml voinetwork"

wait_for_stack_to_be_ready

verify_node_is_running

if [[ -n ${VOINETWORK_SKIP_WALLET_SETUP} && ${VOINETWORK_SKIP_WALLET_SETUP} -eq 1  ]]; then
  display_banner "Wallet setup will be skipped."

  joined_network_instructions

  echo "The network is now catching up and will continue to do so in the background."
  exit 0
fi

display_banner "Initiating setup for Voi wallets and accounts."

create_wallet

if [[ -n ${VOINETWORK_IMPORT_ACCOUNT} && ${VOINETWORK_IMPORT_ACCOUNT} -eq 1 ]]; then

  if ! (check_if_account_exists true); then
    echo "An account already exists. No need to import, skipping this step."
  else
    echo ""
    echo "Let's proceed to import an account using your existing account mnemonic."
    execute_interactive_docker_command "goal account import"
    get_account_address
  fi

else
  if check_if_account_exists; then
    execute_interactive_docker_command "goal account new"

    # Get Voi from faucet
    echo "****************************************************************************************************************"
    echo "*    To join the Voi network, do one of these:"
    echo "*"
    echo "*    a) Send at least 1 Voi to your account ${account_addr} from another account"
    echo "*"
    echo "*    OR"
    echo "*"
    echo "*    b) Get 1 Voi for free:"
    echo "*       - Go to the Voi Network Discord - https://discord.com/invite/vnFbrJrHeW"
    echo "*       - Find the #node-runners channel"
    echo "*       - Type /voi-testnet-faucet ${account_addr}"
    echo "*"
    echo "* After you've done this, type 'completed' to go on"
    echo "****************************************************************************************************************"

    read -p "Type 'completed' when you're ready to continue: " prompt
    while [ "${prompt}" != "completed" ]
    do
      read -p "Type 'completed' to continue: " prompt
    done
  fi
fi

# Catchup node before creating participation key and going online
catchup_node

if [[ "${skip_account_setup}" -eq 0 ]]; then
  display_banner "Joining network"

  generate_participation_key

  busy_wait_until_balance_is_1_voi

  execute_interactive_docker_command "goal account changeonlinestatus -a ${account_addr}"

  account_status=$(execute_docker_command "goal account dump -a ${account_addr}" | jq -r .onl)
fi

if [[ "${skip_account_setup}" -eq 0 ]]; then
  if [[ "${account_status}" -eq 1 ]]; then
    display_banner "Welcome to Voi! You are now online!"
   joined_network_instructions
  else
   display_banner "Your account ${account_addr} is currently offline."
   echo "There seems to be an issue with going online. Please seek assistance in the #node-help channel on the Voi Network Discord."
   echo "Join us at: https://discord.com/invite/vnFbrJrHeW"
   abort "Exiting the program."
  fi

  echo "PLEASE SAVE THIS INFORMATION SAFELY"
  echo "***********************************"
  echo "Your Voi address: ${account_addr}"
  echo "Enter password to get your account recovery mnemonic. Store your mnemonic safely:"

  execute_interactive_docker_command "goal account export -a ${account_addr}"
else
  display_banner "Welcome to Voi!"

  joined_network_instructions
fi
